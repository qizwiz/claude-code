#!/usr/bin/env python3
"""
Simplified Provenance MCP Server
"""

import asyncio
from mcp.server import Server
from mcp.types import Tool, TextContent

# Create server instance
app = Server("provenance-verifier")

@app.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="verify_claim",
            description="Verify if a claim has sufficient evidence",
            inputSchema={
                "type": "object",
                "properties": {
                    "claim": {"type": "string", "description": "The claim to verify"}
                },
                "required": ["claim"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "verify_claim":
        claim = arguments.get("claim", "")
        
        # Simple verification logic
        verified_claims = [
            "the sky is blue",
            "water boils at 100 degrees celsius",
            "python is a programming language"
        ]
        
        is_verified = any(verified.lower() in claim.lower() for verified in verified_claims)
        
        result = {
            "claim": claim,
            "verified": is_verified,
            "confidence": 90 if is_verified else 10,
            "evidence_count": 1 if is_verified else 0
        }
        
        return [TextContent(
            type="text",
            text=f"Claim verification result: {result}"
        )]
    
    raise ValueError(f"Unknown tool: {name}")

async def main():
    from mcp.server.stdio import stdio_server
    
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())