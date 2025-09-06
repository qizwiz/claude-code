#!/usr/bin/env node

/**
 * Claude Code MCP Protocol Fix
 * 
 * Fixes missing protocolVersion parameter in MCP initialize requests
 * that causes "failing MCP servers" messages in Claude Code.
 */

const { execSync } = require('child_process');
const fs = require('fs');

const MCP_PROTOCOL_VERSION = '2024-11-05';

// Detect MCP servers from config files
function detectMcpServers() {
    const configs = [
        `${process.env.HOME}/.claude/.mcp.json`,
        `${process.env.HOME}/.claude/settings.json`,
        `${process.cwd()}/.mcp.json`
    ];
    
    let servers = [];
    for (const configPath of configs) {
        try {
            const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
            if (config.mcpServers) {
                servers.push(...Object.keys(config.mcpServers));
            }
            if (config.enabledMcpjsonServers) {
                servers.push(...config.enabledMcpjsonServers);
            }
        } catch (e) {
            // Config doesn't exist or is invalid
        }
    }
    
    return servers;
}

console.log('🔧 Claude Code MCP Protocol Fix');
console.log(`✅ Protocol Version: ${MCP_PROTOCOL_VERSION}`);

const servers = detectMcpServers();
if (servers.length > 0) {
    console.log(`🔍 Detected MCP servers: ${servers.join(', ')}`);
}

// Create wrapper that patches MCP initialize requests
const wrapperCode = `
const originalSpawn = require('child_process').spawn;

require('child_process').spawn = function(command, args, options) {
    const child = originalSpawn.apply(this, arguments);
    
    if (child && child.stdin && typeof child.stdin.write === 'function') {
        const originalWrite = child.stdin.write;
        
        child.stdin.write = function(data, encoding, callback) {
            let modifiedData = data;
            
            try {
            try {
                const str = Buffer.isBuffer(data) ? data.toString('utf8') : String(data);
                const clMatch = str.match(/^Content-Length:\s*(\d+)\r?\n\r?\n/);
                const parseAndPatch = (body) => {
                  const message = JSON.parse(body);
                  if (message.method === 'initialize') {
                    message.params ||= {};
                    if (!message.params.protocolVersion) {
                      message.params.protocolVersion = '${MCP_PROTOCOL_VERSION}';
                      console.error('🔧 [MCP-FIX] Added missing protocolVersion');
                    }
                    if (!message.params.clientInfo) {
                      message.params.clientInfo = { name: 'claude-code-fixed', version: '1.0.x-mcp-patched' };
                    }
                    message.params.capabilities ||= {};
                  }
                  return message;
                };

                if (clMatch) {
                  const [, ] = clMatch;
                  const body = str.split(/\r?\n\r?\n/)[1] ?? '';
                  const patched = parseAndPatch(body);
                  const newBody = JSON.stringify(patched);
                  const newHeader = 'Content-Length: ' + Buffer.byteLength(newBody, 'utf8') + '\\r\\n\\r\\n';
                  modifiedData = newHeader + newBody;
                } else {
                  const patched = parseAndPatch(str.trim());
                  modifiedData = JSON.stringify(patched) + '\\n';
                }
            } catch (e) {
                // Not JSON - pass through unchanged
            }
                // Not JSON - pass through unchanged
            }
            
            return originalWrite.call(this, modifiedData, encoding, callback);
        };
    }
    
    return child;
};
`;

// Write wrapper to temp file
const wrapperPath = '/tmp/claude-mcp-wrapper.js';
fs.writeFileSync(wrapperPath, wrapperCode);

// Set Node options to load our wrapper
const env = { ...process.env };
env.NODE_OPTIONS = `--require=${wrapperPath} ${env.NODE_OPTIONS || ''}`;

// Launch Claude Code with the wrapper
try {
    const result = execSync(`claude ${process.argv.slice(2).join(' ')}`, {
        stdio: 'inherit',
        env: env,
        encoding: 'utf8'
    });
} catch (error) {
    process.exit(error.status || 1);
} finally {
    // Cleanup temp file
    try {
        fs.unlinkSync(wrapperPath);
    } catch (e) {
        // Ignore cleanup errors
    }
}