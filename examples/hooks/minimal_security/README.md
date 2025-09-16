# Minimal Security Hook

A simple client-side secret detection hook for Claude Code that prevents accidental secret exposure.

## Features

- Detects common API keys and tokens (OpenAI, Anthropic, AWS, GitHub, Google, Slack, JWT)
- Blocks execution if secrets are detected in commands
- Fail-safe design that allows execution if errors occur

## Installation

Add to your Claude Code `settings.json`:

```json
{
  "preToolUseHooks": [
    {
      "path": "./examples/hooks/minimal_security/hook.py"
    }
  ]
}
```

## Usage

The hook automatically runs before each tool execution and blocks commands that contain potential secrets.

## How It Works

The hook reads tool input from stdin, checks for common secret patterns, and exits with code 2 to block execution if any secrets are found.

## Files

- `hook.py` - The 60-line security hook implementation
