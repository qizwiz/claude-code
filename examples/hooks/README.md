# Security Demo Hook

A minimal proof-of-concept hook that demonstrates client-side secret detection for Claude Code, addressing Issue #2695.

## Features

- Detects common API keys (OpenAI, Anthropic, AWS) before transmission
- Blocks execution when secrets are found
- Fail-safe design (allows execution on errors)
- 65 lines of code for easy review

## Usage

Add to your Claude Code `settings.json`:

```json
{
  "preToolUseHooks": [
    {
      "path": "./examples/hooks/security_demo.py"
    }
  ]
}
```

## Testing

```bash
# Test with safe command
echo '{"tool_name": "Bash", "tool_input": {"command": "echo hello"}}' | python3 security_demo.py
echo $?  # Should be 0 (allowed)

# Test with secret
echo '{"tool_name": "Bash", "tool_input": {"command": "export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef12"}}' | python3 security_demo.py
echo $?  # Should be 2 (blocked)
```

## Supported Secret Types

- OpenAI API Keys (`sk-` followed by 48 characters)
- Anthropic API Keys (`sk-ant-` followed by 94 characters and ending with `R`)
- AWS Access Keys (`AKIA` followed by 16 uppercase letters/numbers)

## Design Philosophy

This is a minimal implementation focused on:
- Proving the concept works
- Providing immediate value
- Keeping complexity low
- Serving as a foundation for community development

For comprehensive security features, see enterprise security libraries.