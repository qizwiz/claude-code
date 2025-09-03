#!/usr/bin/env python3
"""
Security Demo Hook for Claude Code
==================================
Minimal client-side secret detection before tool execution.
Addresses Issue #2695 with improved proof-of-concept.

For production use, see: https://github.com/anthropics/zero-trust-ai-security
"""

import json
import sys
import re
from typing import List, Tuple

# More precise secret patterns to reduce false positives
# Based on current public API key formats
SECRET_PATTERNS = {
    'OPENAI_API_KEY': r'sk-[a-zA-Z0-9]{48}',  # 51 chars total
    'ANTHROPIC_API_KEY': r'sk-ant-[a-zA-Z0-9_-]{90,100}[A-Za-z0-9]',  # Approximate pattern
    'AWS_ACCESS_KEY': r'AKIA[0-9A-Z]{16}',  # 20 chars total
}

def detect_secrets(text: str) -> List[Tuple[str, str]]:
    """Detect secrets in text content with basic validation"""
    secrets_found = []
    
    # Skip if text looks like a test/example to reduce false positives
    # But be more specific about what constitutes a test pattern
    if 'EXAMPLE' not in text and any(test_word in text.lower() for test_word in ['test', 'sample', 'dummy']):
        return secrets_found
    
    for secret_type, pattern in SECRET_PATTERNS.items():
        matches = re.finditer(pattern, text)
        for match in matches:
            secret = match.group()
            # Additional validation to reduce false positives
            if len(secret) >= 20:  # Minimum reasonable length
                secrets_found.append((secret, secret_type))
    return secrets_found

def main():
    """Main hook entry point with improved error handling"""
    try:
        # Read tool call from stdin
        input_data = sys.stdin.read().strip()
        if not input_data:
            sys.exit(0)
        
        # Parse JSON with explicit error handling
        try:
            tool_call = json.loads(input_data)
        except json.JSONDecodeError as e:
            print(f"Security Hook Error: Invalid JSON input - {str(e)}", file=sys.stderr)
            sys.exit(1)  # Reject invalid input
            
        # Extract text content from tool call
        tool_input = tool_call.get('tool_input', {})
        
        # Focus on command field where secrets are most likely to appear
        text_content = ""
        if 'command' in tool_input:
            text_content = str(tool_input['command'])
        else:
            # Fallback to checking all string values
            for key, value in tool_input.items():
                if isinstance(value, str):
                    text_content += " " + value
        
        # Early exit for empty or very short content
        if len(text_content.strip()) < 5:
            sys.exit(0)
        
        # Check for secrets
        secrets = detect_secrets(text_content)
        
        if secrets:
            print("🔒 SECURITY ALERT: Potential secrets detected!", file=sys.stderr)
            for secret, secret_type in secrets:
                # Consistent masking
                masked = secret[:8] + "..." if len(secret) > 11 else secret[:3] + "..."
                print(f"  • {secret_type}: {masked}", file=sys.stderr)
            print("\nBlocking execution to prevent potential secret transmission.", file=sys.stderr)
            print("See documentation for secure configuration options.", file=sys.stderr)
            sys.exit(2)  # Block execution
        
        # No secrets found - allow execution
        sys.exit(0)
        
    except KeyboardInterrupt:
        # Always respect user interruption
        sys.exit(1)
    except MemoryError:
        # Handle resource exhaustion explicitly
        print("Security Hook Error: Insufficient memory", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        # Log unexpected errors but don't fail silently
        print(f"Security Hook Warning: Internal error - {str(e)}", file=sys.stderr)
        print("Falling back to permissive mode.", file=sys.stderr)
        sys.exit(0)  # Allow execution but warn

if __name__ == "__main__":
    main()