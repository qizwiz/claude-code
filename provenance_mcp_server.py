#!/usr/bin/env python3
"""
Provenance Verification MCP Server
Prevents AI assistants from making unverified claims
"""

import asyncio
import sys
from typing import List, Dict, Any, Optional
from mcp.server import Server
from mcp.types import Resource, Tool, TextContent
import json
import hashlib
from datetime import datetime

# Evidence record structure
class EvidenceRecord:
    def __init__(self, content: str, source_url: str, verified: bool, timestamp: int = None):
        self.content = content
        self.source_url = source_url
        self.verified = verified
        self.timestamp = timestamp or int(datetime.now().timestamp())
        self.hash = hashlib.sha256(f"{content}{source_url}".encode()).hexdigest()[:8]

class ProvenanceVerifier:
    def __init__(self, confidence_threshold: int = 80):
        self.confidence_threshold = confidence_threshold
        self.evidence_db = self._build_evidence_db()
    
    def _build_evidence_db(self) -> Dict[str, List[EvidenceRecord]]:
        """Build evidence database - in practice would be external"""
        return {
            "Several MCP servers exist": [
                EvidenceRecord(
                    "GitHub repo devshark/fact-checker-mcp verified to exist",
                    "https://github.com/devshark/fact-checker-mcp",
                    True
                )
            ],
            "MCP servers for fact checking": [
                EvidenceRecord(
                    "Search results mention fact-checker-mcp",
                    "web_search_results",
                    False
                ),
                EvidenceRecord(
                    "Verified devshark/fact-checker-mcp repository exists",
                    "https://github.com/devshark/fact-checker-mcp",
                    True
                )
            ]
        }
    
    def calculate_confidence(self, evidence_chain: List[EvidenceRecord]) -> int:
        if not evidence_chain:
            return 0
        verified_count = sum(1 for e in evidence_chain if e.verified)
        return (verified_count * 100) // len(evidence_chain)
    
    def verify_claim(self, claim: str) -> Dict[str, Any]:
        """Main verification function"""
        evidence_chain = self.evidence_db.get(claim, [])
        
        has_evidence = len(evidence_chain) > 0
        all_verified = all(e.verified for e in evidence_chain) if evidence_chain else False
        confidence = self.calculate_confidence(evidence_chain)
        meets_threshold = confidence >= self.confidence_threshold
        
        is_assertable = has_evidence and all_verified and meets_threshold
        
        return {
            "claim": claim,
            "assertable": is_assertable,
            "confidence": confidence,
            "evidence_count": len(evidence_chain),
            "verified_count": sum(1 for e in evidence_chain if e.verified),
            "evidence": [
                {
                    "content": e.content,
                    "source_url": e.source_url,
                    "verified": e.verified,
                    "hash": e.hash
                }
                for e in evidence_chain
            ],
            "message": "✅ Claim verified with sufficient evidence" if is_assertable 
                      else "❌ Claim lacks sufficient verified evidence"
        }

# Initialize MCP server and verifier
app = Server("provenance-verifier")
verifier = ProvenanceVerifier()

@app.list_tools()
async def list_tools() -> List[Tool]:
    return [
        Tool(
            name="verify_claim",
            description="Verify if a claim has sufficient evidence before assertion",
            inputSchema={
                "type": "object",
                "properties": {
                    "claim": {
                        "type": "string",
                        "description": "The claim to verify"
                    }
                },
                "required": ["claim"]
            }
        ),
        Tool(
            name="check_assertion_safety",
            description="Check if it's safe to make an assertion about a topic",
            inputSchema={
                "type": "object", 
                "properties": {
                    "statement": {
                        "type": "string",
                        "description": "The statement to check for safety"
                    }
                },
                "required": ["statement"]
            }
        )
    ]

@app.call_tool()
async def call_tool(name: str, arguments: Dict[str, Any]) -> List[TextContent]:
    if name == "verify_claim":
        claim = arguments["claim"]
        result = verifier.verify_claim(claim)
        
        return [TextContent(
            type="text",
            text=json.dumps(result, indent=2)
        )]
    
    elif name == "check_assertion_safety":
        statement = arguments["statement"]
        
        # Check common problematic patterns
        problematic_patterns = [
            "several", "many", "multiple", "various",
            "I found", "search reveals", "results show",
            "exists", "available", "there are"
        ]
        
        has_problematic_pattern = any(pattern.lower() in statement.lower() 
                                    for pattern in problematic_patterns)
        
        if has_problematic_pattern:
            # Try to verify the core claim
            result = verifier.verify_claim(statement)
            
            if not result["assertable"]:
                warning = f"""
⚠️  PROVENANCE WARNING ⚠️
Statement: "{statement}"
Issue: Contains assertion patterns without verified evidence
Confidence: {result['confidence']}%
Evidence: {result['evidence_count']} items, {result['verified_count']} verified

RECOMMENDATION: Verify evidence before making this claim
"""
                return [TextContent(type="text", text=warning)]
        
        return [TextContent(
            type="text", 
            text=f"✅ Statement appears safe to assert: {statement}"
        )]
    
    else:
        return [TextContent(type="text", text=f"Unknown tool: {name}")]

@app.list_resources()
async def list_resources() -> List[Resource]:
    return [
        Resource(
            uri="provenance://evidence-db",
            name="Evidence Database",
            mimeType="application/json",
            description="Database of verified evidence for claims"
        )
    ]

async def main():
    # Run the MCP server
    from mcp.server.stdio import stdio_server
    
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())