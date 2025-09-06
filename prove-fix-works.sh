#!/bin/bash

echo "🔬 Proving Claude Code MCP Fix Works"
echo "======================================"

# Test 1: Show the bug exists with original Claude
echo ""
echo "📋 Test 1: Testing original Claude Code (should fail)"
echo "------------------------------------------------------"

# Configure a simple test MCP server
cat > /tmp/test-initialize.py << 'EOF'
#!/usr/bin/env python3
import json
import sys
import time

def main():
    print("[TEST] MCP server starting", file=sys.stderr)
    try:
        for line in sys.stdin:
            request = json.loads(line.strip())
            print(f"[TEST] Received: {request}", file=sys.stderr)
            
            if request.get("method") == "initialize":
                params = request.get("params", {})
                protocol_version = params.get("protocolVersion")
                
                if not protocol_version:
                    print("[TEST] ❌ BUG CONFIRMED: Missing protocolVersion!", file=sys.stderr)
                    error_response = {
                        "jsonrpc": "2.0",
                        "id": request.get("id"),
                        "error": {
                            "code": -32602,
                            "message": "Missing protocolVersion parameter - Claude Code bug confirmed!"
                        }
                    }
                else:
                    print(f"[TEST] ✅ FIXED: Found protocolVersion: {protocol_version}", file=sys.stderr)
                    error_response = {
                        "jsonrpc": "2.0",
                        "id": request.get("id"),
                        "result": {
                            "protocolVersion": "2024-11-05",
                            "capabilities": {},
                            "serverInfo": {"name": "test", "version": "1.0"}
                        }
                    }
                
                print(json.dumps(error_response))
                sys.stdout.flush()
                time.sleep(0.5)  # Give time for response to be processed
                break
                
    except Exception as e:
        print(f"[TEST] Error: {e}", file=sys.stderr)

if __name__ == "__main__":
    main()
EOF

chmod +x /tmp/test-initialize.py

# Create test MCP config
cat > /tmp/test-mcp.json << 'EOF'
{
  "mcpServers": {
    "bug-tester": {
      "command": "python3",
      "args": ["/tmp/test-initialize.py"],
      "env": {}
    }
  }
}
EOF

echo "🧪 Testing original Claude Code with MCP debug..."
timeout 10s claude --mcp-config /tmp/test-mcp.json --mcp-debug --version 2>&1 | grep -E "\[TEST\]|❌|✅" || echo "No test output captured"

echo ""
echo "📋 Test 2: Testing our FIXED Claude Code"
echo "-----------------------------------------"

echo "🔧 Testing fixed Claude Code with same config..."
timeout 10s node /Users/jonathanhill/src/claude-code/mcp-fix-v2.js --mcp-config /tmp/test-mcp.json --mcp-debug --version 2>&1 | grep -E "\[TEST\]|\[MCP-FIX\]|❌|✅" || echo "No test output captured"

echo ""
echo "🧹 Cleanup"
rm -f /tmp/test-initialize.py /tmp/test-mcp.json

echo ""
echo "🎯 Test Results Summary:"
echo "- Original Claude Code: Should show ❌ missing protocolVersion"  
echo "- Fixed Claude Code: Should show ✅ protocolVersion found"
echo "- Fix wrapper: Should show 🔧 [MCP-FIX] messages"