#!/usr/bin/env bun

declare global {
  var process: {
    env: Record<string, string | undefined>;
  };
}

interface GitHubIssue {
  number: number;
  title: string;
  state: string;
  state_reason?: string;
  user: { id: number };
  created_at: string;
  closed_at?: string;
}

interface GitHubComment {
  id: number;
  body: string;
  created_at: string;
  user: { type: string; id: number };
}

async function githubRequest<T>(endpoint: string, token: string, method: string = 'GET', body?: any): Promise<T> {
  const response = await fetch(`https://api.github.com${endpoint}`, {
    method,
    headers: {
      Authorization: `Bearer ${token}`,
      Accept: "application/vnd.github.v3+json",
      "User-Agent": "backfill-duplicate-comments-script",
      ...(body && { "Content-Type": "application/json" }),
    },
    ...(body && { body: JSON.stringify(body) }),
  });

  if (!response.ok) {
    throw new Error(
      `GitHub API request failed: ${response.status} ${response.statusText}`
    );
  }

  return response.json();
}

async function triggerDedupeWorkflow(
  owner: string,
  repo: string,
  issueNumber: number,
  token: string,
  dryRun: boolean = true
): Promise<void> {
  if (dryRun) {
    console.log(`[DRY RUN] Would trigger dedupe workflow for issue #${issueNumber}`);
    return;
  }

  await githubRequest(
    `/repos/${owner}/${repo}/actions/workflows/claude-dedupe-issues.yml/dispatches`,
    token,
    'POST',
    {
      ref: 'main',
      inputs: {
        issue_number: issueNumber.toString()
      }
    }
  );
}

/**
 * Scans repository issues within a numeric range and triggers the Claude dedupe workflow for issues
 * that do not already have a duplicate-detection comment.
 *
 * This function:
 * - Requires GITHUB_TOKEN in the environment (throws if missing) and reads other env vars:
 *   - DRY_RUN (default: true) — set to "false" to actually dispatch workflows.
 *   - MAX_ISSUE_NUMBER (default: 4050) — process issues with number < this value.
 *   - MIN_ISSUE_NUMBER (default: 1) — process issues with number >= this value.
 * - Paginates repository issues (sorted by creation date, newest first), collects issues whose
 *   numbers fall in [MIN_ISSUE_NUMBER, MAX_ISSUE_NUMBER), and for each issue:
 *   - Fetches comments and skips the issue if a bot-created duplicate-detection comment exists.
 *   - Otherwise, invokes the dedupe workflow dispatcher (or logs a dry-run message).
 * - Waits ~1 second between workflow triggers and enforces a page limit to avoid endless pagination.
 *
 * Side effects:
 * - May dispatch GitHub Actions workflows for matching issues (unless DRY_RUN is not "false").
 *
 * @throws Error If the GITHUB_TOKEN environment variable is not set.
 */
async function backfillDuplicateComments(): Promise<void> {
  console.log("[DEBUG] Starting backfill duplicate comments script");

  const token = process.env.GITHUB_TOKEN;
  if (!token) {
    throw new Error(`GITHUB_TOKEN environment variable is required

Usage:
  GITHUB_TOKEN=your_token bun run scripts/backfill-duplicate-comments.ts

Environment Variables:
  GITHUB_TOKEN - GitHub personal access token with repo and actions permissions (required)
  DRY_RUN - Set to "false" to actually trigger workflows (default: true for safety)
  MAX_ISSUE_NUMBER - Only process issues with numbers less than this value (default: 4050)`);
  }
  console.log("[DEBUG] GitHub token found");

  const owner = "anthropics";
  const repo = "claude-code";
  const dryRun = process.env.DRY_RUN !== "false";
  const maxIssueNumber = parseInt(process.env.MAX_ISSUE_NUMBER || "4050", 10);
  const minIssueNumber = parseInt(process.env.MIN_ISSUE_NUMBER || "1", 10);
  
  console.log(`[DEBUG] Repository: ${owner}/${repo}`);
  console.log(`[DEBUG] Dry run mode: ${dryRun}`);
  console.log(`[DEBUG] Looking at issues between #${minIssueNumber} and #${maxIssueNumber}`);

  console.log(`[DEBUG] Fetching issues between #${minIssueNumber} and #${maxIssueNumber}...`);
  const allIssues: GitHubIssue[] = [];
  let page = 1;
  const perPage = 100;
  
  while (true) {
    const pageIssues: GitHubIssue[] = await githubRequest(
      `/repos/${owner}/${repo}/issues?state=all&per_page=${perPage}&page=${page}&sort=created&direction=desc`,
      token
    );
    
    if (pageIssues.length === 0) break;
    
    // Filter to only include issues within the specified range
    const filteredIssues = pageIssues.filter(issue => 
      issue.number >= minIssueNumber && issue.number < maxIssueNumber
    );
    allIssues.push(...filteredIssues);
    
    // If the oldest issue in this page is still above our minimum, we need to continue
    // but if the oldest issue is below our minimum, we can stop
    const oldestIssueInPage = pageIssues[pageIssues.length - 1];
    if (oldestIssueInPage && oldestIssueInPage.number >= maxIssueNumber) {
      console.log(`[DEBUG] Oldest issue in page #${page} is #${oldestIssueInPage.number}, continuing...`);
    } else if (oldestIssueInPage && oldestIssueInPage.number < minIssueNumber) {
      console.log(`[DEBUG] Oldest issue in page #${page} is #${oldestIssueInPage.number}, below minimum, stopping`);
      break;
    } else if (filteredIssues.length === 0 && pageIssues.length > 0) {
      console.log(`[DEBUG] No issues in page #${page} are in range #${minIssueNumber}-#${maxIssueNumber}, continuing...`);
    }
    
    page++;
    
    // Safety limit to avoid infinite loops
    if (page > 200) {
      console.log("[DEBUG] Reached page limit, stopping pagination");
      break;
    }
  }
  
  console.log(`[DEBUG] Found ${allIssues.length} issues between #${minIssueNumber} and #${maxIssueNumber}`);

  let processedCount = 0;
  let candidateCount = 0;
  let triggeredCount = 0;

  for (const issue of allIssues) {
    processedCount++;
    console.log(
      `[DEBUG] Processing issue #${issue.number} (${processedCount}/${allIssues.length}): ${issue.title}`
    );

    console.log(`[DEBUG] Fetching comments for issue #${issue.number}...`);
    const comments: GitHubComment[] = await githubRequest(
      `/repos/${owner}/${repo}/issues/${issue.number}/comments`,
      token
    );
    console.log(
      `[DEBUG] Issue #${issue.number} has ${comments.length} comments`
    );

    // Look for existing duplicate detection comments (from the dedupe bot)
    const dupeDetectionComments = comments.filter(
      (comment) =>
        comment.body.includes("Found") &&
        comment.body.includes("possible duplicate") &&
        comment.user.type === "Bot"
    );

    console.log(
      `[DEBUG] Issue #${issue.number} has ${dupeDetectionComments.length} duplicate detection comments`
    );

    // Skip if there's already a duplicate detection comment
    if (dupeDetectionComments.length > 0) {
      console.log(
        `[DEBUG] Issue #${issue.number} already has duplicate detection comment, skipping`
      );
      continue;
    }

    candidateCount++;
    const issueUrl = `https://github.com/${owner}/${repo}/issues/${issue.number}`;
    
    try {
      console.log(
        `[INFO] ${dryRun ? '[DRY RUN] ' : ''}Triggering dedupe workflow for issue #${issue.number}: ${issueUrl}`
      );
      await triggerDedupeWorkflow(owner, repo, issue.number, token, dryRun);
      
      if (!dryRun) {
        console.log(
          `[SUCCESS] Successfully triggered dedupe workflow for issue #${issue.number}`
        );
      }
      triggeredCount++;
    } catch (error) {
      console.error(
        `[ERROR] Failed to trigger workflow for issue #${issue.number}: ${error}`
      );
    }

    // Add a delay between workflow triggers to avoid overwhelming the system
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log(
    `[DEBUG] Script completed. Processed ${processedCount} issues, found ${candidateCount} candidates without duplicate comments, ${dryRun ? 'would trigger' : 'triggered'} ${triggeredCount} workflows`
  );
}

backfillDuplicateComments().catch(console.error);

// Make it a module
export {};