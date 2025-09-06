#!/usr/bin/env python3
"""
Minimal MCP Server for testing Claude Code MCP protocol fix
"""
import json
import sys

def handle_initialize(params):
    """Handle MCP initialize request"""
    print(f"[TEST-MCP] Received initialize request with params: {params}", file=sys.stderr)
    
    # Check if protocolVersion is present
    protocol_version = params.get('protocolVersion')
    if not protocol_version:
        print("[TEST-MCP] ❌ MISSING protocolVersion - fix failed!", file=sys.stderr)
        return {
            "jsonrpc": "2.0",
            "id": 1,
            "error": {
                "code": -32602,
                "message": "Missing required protocolVersion parameter"
            }
        }
    
    print(f"[TEST-MCP] ✅ Found protocolVersion: {protocol_version} - fix worked!", file=sys.stderr)
    
    return {
        "jsonrpc": "2.0", 
        "id": 1,
        "result": {
            "protocolVersion": "2024-11-05",
            "capabilities": {
                "tools": {},
                "resources": {}
            },
            "serverInfo": {
                "name": "test-mcp-server", 
                "version": "1.0.0"
            }
        }
    }

def main():
    """Simple MCP server for testing"""
    print("[TEST-MCP] Test MCP server started", file=sys.stderr)
    
    try:
        for line in sys.stdin:
            try:
                request = json.loads(line.strip())
                print(f"[TEST-MCP] Received: {request}", file=sys.stderr)
                
                if request.get("method") == "initialize":
                    response = handle_initialize(request.get("params", {}))
                    print(json.dumps(response))
                    sys.stdout.flush()
                    
                    # Exit after first initialize to make testing simple
                    print("[TEST-MCP] Initialize complete, exiting", file=sys.stderr)
                    break
                    
            except json.JSONDecodeError as e:
                print(f"[TEST-MCP] JSON decode error: {e}", file=sys.stderr)
                continue
                
    except KeyboardInterrupt:
        print("[TEST-MCP] Shutting down", file=sys.stderr)
    except Exception as e:
        print(f"[TEST-MCP] Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()