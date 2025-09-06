#!/usr/bin/env node

/**
 * Claude Code MCP Protocol Version Fix v2.0
 * 
 * This script creates a wrapper around Claude Code that intercepts and fixes
 * the missing protocolVersion in MCP initialize requests.
 * 
 * Instead of requiring the binary (which has module issues), we spawn it
 * as a child process and intercept its MCP communications.
 */

const { spawn, execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CLAUDE_BINARY = '/Users/jonathanhill/.bun/bin/claude';
const MCP_PROTOCOL_VERSION = '2024-11-05';

// Enhanced MCP server detection
function detectMcpServers() {
    const configs = [
        '/Users/jonathanhill/.claude/.mcp.json',
        '/Users/jonathanhill/.claude/settings.json',
        process.cwd() + '/.mcp.json'
    ];
    
    let servers = [];
    for (const configPath of configs) {
        try {
            const config = JSON.parse(fs.readFileSync(configPath, 'utf8'));
            
            // Check .mcp.json format
            if (config.mcpServers) {
                servers.push(...Object.keys(config.mcpServers));
            }
            
            // Check settings.json format  
            if (config.enabledMcpjsonServers) {
                servers.push(...config.enabledMcpjsonServers);
            }
        } catch (e) {
            // Config doesn't exist or is invalid
        }
    }
    
    return servers;
}

console.log('🔧 Claude Code MCP Protocol Fix v2.0');
console.log(`✅ Protocol Version Target: ${MCP_PROTOCOL_VERSION}`);

const servers = detectMcpServers();
if (servers.length > 0) {
    console.log(`🔍 Detected MCP servers: ${servers.join(', ')}`);
    console.log('🚀 Starting Claude Code with MCP protocol injection...');
} else {
    console.log('ℹ️  No MCP servers detected - launching normal Claude Code');
}

// Create wrapper script for Node.js child process interception
const wrapperCode = `
const originalSpawn = require('child_process').spawn;
const fs = require('fs');

// Intercept child_process.spawn for MCP servers
require('child_process').spawn = function(command, args, options) {
    const child = originalSpawn.apply(this, arguments);
    
    // Check if this could be an MCP server
    if (options && options.stdio && child.stdin && child.stdout) {
        const originalWrite = child.stdin.write;
        let hasLoggedFix = false;
        
        child.stdin.write = function(data, encoding, callback) {
            let modifiedData = data;
            
            try {
                // Parse JSON-RPC message
                const message = JSON.parse(data.toString());
                
                if (message.method === 'initialize') {
                    if (!hasLoggedFix) {
                        console.error('🔧 [MCP-FIX] Intercepted MCP initialize request');
                        hasLoggedFix = true;
                    }
                    
                    // Add missing protocolVersion if not present
                    if (!message.params) {
                        message.params = {};
                    }
                    
                    if (!message.params.protocolVersion) {
                        message.params.protocolVersion = '${MCP_PROTOCOL_VERSION}';
                        console.error('🔧 [MCP-FIX] Added missing protocolVersion: ${MCP_PROTOCOL_VERSION}');
                    }
                    
                    // Ensure clientInfo exists
                    if (!message.params.clientInfo) {
                        message.params.clientInfo = {
                            name: 'claude-code-fixed',
                            version: '1.0.83-mcp-patched'
                        };
                    }
                    
                    // Ensure capabilities exists
                    if (!message.params.capabilities) {
                        message.params.capabilities = {};
                    }
                    
                    modifiedData = JSON.stringify(message) + '\\n';
                }
            } catch (e) {
                // Not JSON or parsing failed - pass through original data
            }
            
            return originalWrite.call(this, modifiedData, encoding, callback);
        };
    }
    
    return child;
};
`;

// Write wrapper to temp file
const wrapperPath = '/tmp/claude-mcp-wrapper-v2.js';
fs.writeFileSync(wrapperPath, wrapperCode);

// Set Node options to load our wrapper
const env = { ...process.env };
env.NODE_OPTIONS = `--require=${wrapperPath} ${env.NODE_OPTIONS || ''}`;

// Launch Claude Code with the wrapper
try {
    const result = execSync(`${CLAUDE_BINARY} ${process.argv.slice(2).join(' ')}`, {
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