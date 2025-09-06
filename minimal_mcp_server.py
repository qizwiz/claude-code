#!/usr/bin/env python3

import asyncio
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

app = Server("minimal-provenance")

@app.list_tools()
async def list_tools():
    return [
        Tool(
            name="verify_claim", 
            description="Verify a claim",
            inputSchema={
                "type": "object",
                "properties": {"claim": {"type": "string"}},
                "required": ["claim"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "verify_claim":
        return [TextContent(type="text", text="Claim verified")]
    raise ValueError(f"Unknown tool: {name}")

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(read_stream, write_stream, app.create_initialization_options())

if __name__ == "__main__":
    asyncio.run(main())