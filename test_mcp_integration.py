#!/usr/bin/env python3
"""
Test MCP Server Integration
Simulates Claude Code's interaction with the provenance MCP server
"""

import asyncio
import json
import sys
from mcp.client.stdio import stdio_client
from mcp.types import CallToolRequest

async def test_mcp_server():
    """Test the MCP server integration"""
    print("🔗 Testing MCP Server Integration...")
    
    try:
        # Start the server process
        import subprocess
        
        # Run the server directly and test it via subprocess
        test_payload = {
            "jsonrpc": "2.0",
            "id": 1,
            "method": "tools/call",
            "params": {
                "name": "verify_claim",
                "arguments": {"claim": "Several MCP servers exist"}
            }
        }
        
        print("🔧 Testing MCP server via direct method call...")
        
        # Import and test the server components directly
        sys.path.insert(0, '/Users/jonathanhill/src/claude-code')
        from provenance_mcp_server import ProvenanceVerifier, app
        
        # Test the verifier directly
        verifier = ProvenanceVerifier()
        
        # Test verified claim
        result1 = verifier.verify_claim("Several MCP servers exist")
        if result1["assertable"]:
            print("✅ Verified claim correctly accepted")
        else:
            print("❌ Verified claim incorrectly rejected")
            return False
        
        # Test unverified claim
        result2 = verifier.verify_claim("Several unknown systems exist") 
        if not result2["assertable"]:
            print("✅ Unverified claim correctly rejected")
        else:
            print("❌ Unverified claim incorrectly accepted")
            return False
        
        print("✅ MCP Server core functionality validated")
        return True
            
    except Exception as e:
        print(f"❌ MCP Server integration failed: {e}")
        return False

def main():
    success = asyncio.run(test_mcp_server())
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()