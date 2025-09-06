#!/usr/bin/env node

/**
 * Claude Code MCP Protocol Version Fix
 * 
 * This proxy script fixes the protocolVersion validation bug in Claude Code v1.0.83
 * by intercepting and patching MCP initialize requests before they reach MCP servers.
 * 
 * Bug: GitHub Issues #1611, #768, #4793
 * - Claude Code omits protocolVersion in MCP initialize requests
 * - MCP servers reject invalid initialization
 * - Results in persistent "2 mcp servers failing" messages
 */

const { execSync } = require('child_process');
const fs = require('fs');

// Configuration
const MCP_PROTOCOL_VERSION = '2024-11-05';
const CLAUDE_BINARY = '/Users/jonathanhill/.bun/bin/claude';

console.log('🔧 Claude Code MCP Protocol Fix v1.0');
console.log('📋 Fixing protocolVersion validation bug in Claude Code v1.0.83');
console.log(`✅ Target Protocol Version: ${MCP_PROTOCOL_VERSION}`);

// Check if we have MCP servers configured
const mcp_config_paths = [
    '/Users/jonathanhill/.claude/.mcp.json',
    '/Users/jonathanhill/src/claude-code/.mcp.json',
    '/Users/jonathanhill/src/redis-ai-challenge/.mcp.json'
];

let has_mcp_servers = false;
for (const config_path of mcp_config_paths) {
    try {
        const config = JSON.parse(fs.readFileSync(config_path, 'utf8'));
        if (config.mcpServers && Object.keys(config.mcpServers).length > 0) {
            has_mcp_servers = true;
            console.log(`📁 Found MCP servers in: ${config_path}`);
            console.log(`🔍 Servers: ${Object.keys(config.mcpServers).join(', ')}`);
        }
    } catch (e) {
        // Config file doesn't exist or is invalid, continue
    }
}

if (!has_mcp_servers) {
    console.log('ℹ️  No MCP servers configured - fix not needed, launching normal Claude Code');
    try {
        execSync(`${CLAUDE_BINARY} ${process.argv.slice(2).join(' ')}`, { 
            stdio: 'inherit',
            env: process.env 
        });
    } catch (e) {
        process.exit(e.status || 1);
    }
    process.exit(0);
}

// Create a patched environment with protocol version fix
const originalEnv = process.env;

// Method 1: Environment variable to force protocol version
process.env.MCP_PROTOCOL_VERSION = MCP_PROTOCOL_VERSION;

// Method 2: Create a wrapper script for MCP communication
const wrapperScript = `
const originalSpawn = require('child_process').spawn;
const originalFork = require('child_process').fork;

// Intercept child process creation for MCP servers
require('child_process').spawn = function(...args) {
    const child = originalSpawn.apply(this, args);
    
    // If this is likely an MCP server (has stdio pipes), wrap communication
    if (child.stdin && child.stdout) {
        const originalWrite = child.stdin.write;
        child.stdin.write = function(data) {
            try {
                const message = JSON.parse(data.toString());
                if (message.method === 'initialize' && !message.params?.protocolVersion) {
                    console.log('🔧 [MCP-FIX] Adding missing protocolVersion to initialize request');
                    message.params = message.params || {};
                    message.params.protocolVersion = '${MCP_PROTOCOL_VERSION}';
                    message.params.clientInfo = message.params.clientInfo || {
                        name: 'claude-code-fixed',
                        version: '1.0.83-mcp-patched'
                    };
                    data = JSON.stringify(message) + '\\n';
                }
            } catch (e) {
                // If not JSON or parsing fails, pass through
            }
            return originalWrite.call(this, data);
        };
    }
    
    return child;
};
`;

// Write the wrapper to a temporary file
const wrapperPath = '/tmp/claude-mcp-wrapper.js';
fs.writeFileSync(wrapperPath, wrapperScript);

// Method 3: Use NODE_OPTIONS to require our wrapper
process.env.NODE_OPTIONS = `--require=${wrapperPath} ${process.env.NODE_OPTIONS || ''}`;

console.log('🚀 Launching Claude Code with MCP protocol fix...');
console.log('🔧 Protocol version injection enabled');

try {
    execSync(`${CLAUDE_BINARY} ${process.argv.slice(2).join(' ')}`, { 
        stdio: 'inherit',
        env: process.env 
    });
} catch (e) {
    console.error('❌ Error running Claude Code:', e.message);
    process.exit(e.status || 1);
} finally {
    // Cleanup
    try {
        fs.unlinkSync(wrapperPath);
    } catch (e) {
        // Ignore cleanup errors
    }
}