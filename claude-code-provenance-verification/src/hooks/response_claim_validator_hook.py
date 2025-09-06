#!/usr/bin/env python3
"""
Response Claim Validation Hook for Claude Code
Intercepts tool calls and validates claims before execution
"""

import sys
import json
import re
from typing import List, Dict, Any

# Patterns that indicate potential unverified claims
CLAIM_PATTERNS = [
    r'\b(several|many|multiple|various)\b.*\b(exist|available|servers?|tools?|systems?)\b',
    r'\bi found\b.*\b(servers?|tools?|systems?|evidence)\b',
    r'\bsearch reveals?\b.*\b(exist|available|show)\b',
    r'\bresults? shows?\b.*\b(exist|available|that)\b',
    r'\bthere are\b.*\b(servers?|tools?|systems?)\b',
    r'\bthe [^.]*? (?:reveals?|shows?|indicates?)\b',
    r'\b(?:extensive|comprehensive|numerous)\b.*\b(?:infrastructure|systems?|servers?)\b'
]

def contains_potential_claim(text: str) -> List[str]:
    """Check if text contains patterns that suggest unverified claims"""
    found_claims = []
    text_lower = text.lower()
    
    for pattern in CLAIM_PATTERNS:
        matches = re.findall(pattern, text_lower, re.IGNORECASE)
        if matches:
            # Extract the broader context around the match
            for match in re.finditer(pattern, text_lower, re.IGNORECASE):
                start = max(0, match.start() - 50)
                end = min(len(text), match.end() + 50)
                context = text[start:end].strip()
                found_claims.append(context)
    
    return found_claims

def call_provenance_verifier(claim: str) -> Dict[str, Any]:
    """Call our provenance MCP server to verify a claim"""
    try:
        # Simulate that only very specific verified claims pass
        verified_claims = [
            "the sky is blue",
            "water boils at 100 degrees celsius", 
            "python is a programming language"
        ]
        
        # Check if this is a known verified claim
        if any(verified.lower() in claim.lower() for verified in verified_claims):
            return {"assertable": True, "confidence": 100, "evidence_count": 1}
        
        # All other claims (especially those with problematic patterns) are unverified
        return {"assertable": False, "confidence": 20, "evidence_count": 0}
            
    except Exception as e:
        print(f"Provenance verification error: {e}", file=sys.stderr)
        return {"assertable": False, "confidence": 0, "evidence_count": 0}

def validate_tool_input(tool_data: Dict[str, Any]) -> bool:
    """Validate tool input for unverified claims"""
    tool_name = tool_data.get("tool_name", "")
    tool_input = tool_data.get("tool_input", {})
    
    # Extract text content from various tool inputs
    text_to_check = ""
    
    if isinstance(tool_input, dict):
        # Common text fields across different tools
        for field in ["command", "content", "message", "prompt", "text", "description"]:
            if field in tool_input:
                text_to_check += str(tool_input[field]) + " "
    elif isinstance(tool_input, str):
        text_to_check = tool_input
    
    if not text_to_check.strip():
        return True  # No text to validate
    
    # Check for potential claims
    potential_claims = contains_potential_claim(text_to_check)
    
    if not potential_claims:
        return True  # No claims detected
    
    print(f"🔍 CLAIM VALIDATION: Found {len(potential_claims)} potential claims", file=sys.stderr)
    
    # Verify each potential claim
    blocked_claims = []
    
    for claim in potential_claims:
        verification = call_provenance_verifier(claim)
        
        print(f"   Claim: '{claim[:50]}...'", file=sys.stderr)
        print(f"   Confidence: {verification['confidence']}%", file=sys.stderr)
        print(f"   Evidence: {verification['evidence_count']} items", file=sys.stderr)
        
        if not verification["assertable"]:
            blocked_claims.append(claim)
    
    if blocked_claims:
        print(f"\n❌ BLOCKED: {len(blocked_claims)} unverified claims detected:", file=sys.stderr)
        for i, claim in enumerate(blocked_claims, 1):
            print(f"   {i}. {claim[:80]}{'...' if len(claim) > 80 else ''}", file=sys.stderr)
        
        print(f"\n💡 RECOMMENDATION: Verify these claims before making assertions", file=sys.stderr)
        print(f"   Use tools like WebFetch to verify external claims", file=sys.stderr)
        print(f"   Provide evidence sources for factual statements", file=sys.stderr)
        
        return False  # Block execution
    
    return True  # Allow execution

def main():
    """Main hook entry point"""
    try:
        # Read tool data from stdin
        tool_data = json.load(sys.stdin)
        
        # Validate the tool input for claims
        if validate_tool_input(tool_data):
            print("✅ Response validation passed", file=sys.stderr)
            sys.exit(0)  # Allow execution
        else:
            print("❌ Response validation failed - blocking execution", file=sys.stderr)
            sys.exit(2)  # Block execution with explanation
            
    except json.JSONDecodeError:
        print("Error: Invalid JSON input", file=sys.stderr)
        sys.exit(0)  # Allow on parsing errors (fail-safe)
        
    except Exception as e:
        print(f"Hook error: {e}", file=sys.stderr)
        sys.exit(0)  # Allow on errors (fail-safe)

if __name__ == "__main__":
    main()