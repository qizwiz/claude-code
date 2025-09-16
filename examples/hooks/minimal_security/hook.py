#!/usr/bin/env python3
"""
Minimal Security Hook for Claude Code
Simple client-side secret detection to prevent accidental secret exposure.
"""

import sys
import json
import re

# Simple patterns for common API keys and tokens
SECRET_PATTERNS = [
    r"sk-[a-zA-Z0-9]{48}",              # OpenAI API key
    r"sk-ant-[a-zA-Z0-9_-]{90,100}[A-Za-z0-9]",  # Anthropic API key
    r"AKIA[0-9A-Z]{16}",                # AWS Access Key
    r"ghp_[a-zA-Z0-9]{36}",             # GitHub Personal Access Token
    r"AIza[0-9A-Za-z_-]{35}",           # Google API Key
    r"xox[baprs]-[0-9a-zA-Z]{10,48}",   # Slack Token
    r"eyJ[A-Za-z0-9-_]*\.[A-Za-z0-9-_]*\.[A-Za-z0-9-_]*"  # JWT
]

def detect_secrets(text):
    """Detect if text contains any secret patterns"""
    for pattern in SECRET_PATTERNS:
        if re.search(pattern, text):
            return True
    return False

def main():
    """Main hook function"""
    # Read the tool input from stdin
    input_data = sys.stdin.read().strip()
    
    if not input_data:
        sys.exit(0)
    
    try:
        # Parse the JSON input
        tool_call = json.loads(input_data)
        
        # Check for secrets in the command/input
        command = tool_call.get("tool_input", {}).get("command", "")
        
        if detect_secrets(command):
            print("🔒 SECURITY ALERT: Potential secrets detected!", file=sys.stderr)
            print("Blocking execution to prevent accidental secret exposure.", file=sys.stderr)
            sys.exit(2)  # Exit with error code to block execution
            
        # If no secrets found, allow execution
        sys.exit(0)
        
    except json.JSONDecodeError:
        # If we can't parse JSON, allow execution (fail safe)
        sys.exit(0)
    except Exception:
        # If any other error occurs, allow execution (fail safe)
        sys.exit(0)

if __name__ == "__main__":
    main()
