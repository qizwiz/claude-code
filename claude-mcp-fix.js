#!/usr/bin/env node

/*
 * Claude Code MCP ProtocolVersion Fix
 * 
 * This script patches the MCP server initialization bug in Claude Code v1.0.83
 * where protocolVersion is not properly included in initialize requests.
 * 
 * Bug Details (GitHub Issues #1611, #768, #4793):
 * - Claude Code fails to pass protocolVersion field during MCP server initialization
 * - Causes "2 mcp servers failing" persistent error messages
 * - Affects stdio MCP server configurations
 * 
 * Fix Strategy:
 * 1. Intercept MCP server spawn calls
 * 2. Wrap stdio communication to inject missing protocolVersion
 * 3. Forward all other functionality to original Claude Code
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

// Path to the original Claude Code binary
const ORIGINAL_CLAUDE = '/Users/jonathanhill/.bun/bin/claude';
const MCP_PROTOCOL_VERSION = '2024-11-05';

// Store original spawn function
const originalSpawn = spawn;

// MCP server communication wrapper
function wrapMcpServerComm(child) {
    if (!child.stdin || !child.stdout) return;

    const originalWrite = child.stdin.write;
    
    child.stdin.write = function(data, ...args) {
        try {
            // Check if this is an MCP initialize request
            const message = JSON.parse(data.toString());
            
            if (message.method === 'initialize' && !message.params?.protocolVersion) {
                console.log('🔧 [MCP-FIX] Injecting missing protocolVersion in initialize request');
                
                // Fix the missing protocolVersion
                message.params = message.params || {};
                message.params.protocolVersion = MCP_PROTOCOL_VERSION;
                
                // Add clientInfo if missing
                if (!message.params.clientInfo) {
                    message.params.clientInfo = {
                        name: 'claude-code-patched',
                        version: '1.0.83-mcp-fix'
                    };
                }
                
                // Add capabilities if missing
                if (!message.params.capabilities) {
                    message.params.capabilities = {};
                }
                
                const fixedData = JSON.stringify(message) + '\n';
                return originalWrite.call(this, fixedData, ...args);
            }
        } catch (e) {
            // If parsing fails, pass through original data
        }
        
        return originalWrite.call(this, data, ...args);
    };
}

// Patch child_process.spawn to intercept MCP server launches
require('child_process').spawn = function(command, args, options) {
    const child = originalSpawn.call(this, command, args, options);
    
    // Check if this looks like an MCP server launch
    if (options?.stdio && (
        (Array.isArray(options.stdio) && options.stdio.includes('pipe')) ||
        options.stdio === 'pipe'
    )) {
        console.log('🔍 [MCP-FIX] Detected potential MCP server spawn, wrapping communication');
        wrapMcpServerComm(child);
    }
    
    return child;
};

// Execute original Claude Code with patched environment
console.log('🚀 [MCP-FIX] Starting Claude Code with MCP protocol version fix...');
console.log(`📋 [MCP-FIX] Protocol Version: ${MCP_PROTOCOL_VERSION}`);

// Import and execute the original Claude Code
try {
    require(ORIGINAL_CLAUDE);
} catch (error) {
    console.error('❌ [MCP-FIX] Failed to load original Claude Code:', error.message);
    process.exit(1);
}