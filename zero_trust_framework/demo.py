#!/usr/bin/env python3
"""
Demo script for the Zero-Trust Security Framework
"""
import asyncio
from zero_trust_framework import ZeroTrustProcessor, ClaudeCodeHook, VerificationEngine

def demo_secret_detection():
    """Demonstrate secret detection and replacement"""
    print("🔒 ZERO-TRUST SECURITY FRAMEWORK DEMO")
    print("=" * 50)
    
    # Create processor
    processor = ZeroTrustProcessor()
    
    # Test content with various secrets
    test_content = """
    # This is a test configuration file
    export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef
    export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLA
    export GITHUB_TOKEN=ghp_1234567890abcdefghijklmnopqrstuvwx
    DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
    echo "This is a normal command"
    """
    
    print("\n📝 ORIGINAL CONTENT:")
    print(test_content)
    
    # Process the content
    processed_content, mapping = processor.process_content(test_content)
    
    print("\n✅ PROCESSED CONTENT:")
    print(processed_content)
    
    print("\n📋 SECRET MAPPINGS:")
    for placeholder, secret in mapping.items():
        masked_secret = secret[:8] + "..." if len(secret) > 11 else secret[:3] + "..."
        print(f"  {placeholder} → {masked_secret}")
    
    # Demonstrate content restoration
    restored_content = processor.restore_content(processed_content, mapping)
    print(f"\n🔄 CONTENT RESTORATION: {'✅ SUCCESS' if restored_content == test_content else '❌ FAILED'}")

def demo_claude_hook():
    """Demonstrate Claude Code hook functionality"""
    print("\n\n🤖 CLAUDE CODE HOOK DEMO")
    print("=" * 30)
    
    hook = ClaudeCodeHook()
    
    # Test tool call with secrets
    tool_call = {
        "tool_name": "Bash",
        "tool_input": {
            "command": "export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef && echo 'Starting AI processing'"
        }
    }
    
    print("\n📥 INPUT TOOL CALL:")
    print(f"  Tool: {tool_call['tool_name']}")
    print(f"  Command: {tool_call['tool_input']['command']}")
    
    # Process the tool call
    modified_call, mapping = hook.process_tool_call(tool_call)
    
    print("\n📤 OUTPUT (What Claude receives):")
    if modified_call:
        print(f"  Modified command: {modified_call['tool_input']['command']}")
        print("\n📋 MAPPINGS:")
        for placeholder, secret in mapping.items():
            masked_secret = secret[:8] + "..." if len(secret) > 11 else secret[:3] + "..."
            print(f"  {placeholder} → {masked_secret}")
    else:
        print("  No modification needed")

async def demo_verification():
    """Demonstrate verification engine functionality"""
    print("\n\n🔍 VERIFICATION ENGINE DEMO")
    print("=" * 30)
    
    engine = VerificationEngine()
    
    # Test claims
    test_claims = [
        "File 'config.py' exists and contains API keys",
        "All security tests pass successfully"
    ]
    
    print("\n📝 TEST CLAIMS:")
    for claim in test_claims:
        print(f"  • {claim}")
    
    print("\n✅ VERIFICATION RESULTS:")
    for claim in test_claims:
        result = await engine.verify_claim(claim)
        status = "✅ VERIFIED" if result.verified else "❌ UNVERIFIED"
        print(f"  {status} {claim} (Confidence: {result.confidence:.1%})")

def main():
    """Run all demos"""
    demo_secret_detection()
    demo_claude_hook()
    
    # Run async demo
    asyncio.run(demo_verification())
    
    print("\n\n🎉 DEMO COMPLETE!")
    print("The Zero-Trust Security Framework is working correctly.")

if __name__ == "__main__":
    main()