#!/usr/bin/env python3
"""
Real-World Integration Test
Tests the verification system with actual scenarios Claude Code might encounter
"""

import json
import subprocess
import sys
import tempfile

def test_scenario_1_secret_detection_with_claims():
    """Test: User asks Claude to analyze code with embedded secrets and unverified claims"""
    print("📋 Scenario 1: Code analysis with secrets and claims")
    
    # Simulate user request: "Analyze this configuration and tell me about MCP servers"
    code_with_secrets = '''
    # Configuration file
    OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef
    ANTHROPIC_KEY=sk-ant-api03-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdefR
    DATABASE_URL=postgresql://user:pass@localhost/db
    
    # Several MCP servers are available for fact checking
    # Many systems exist in the ecosystem
    '''
    
    # Step 1: Zero trust should detect and replace secrets
    tool_call = {
        "tool_name": "Write",
        "tool_input": {
            "file_path": "/tmp/config.py",
            "content": code_with_secrets
        }
    }
    
    result = run_hook("examples/hooks/zero_trust_security/hook.py", tool_call)
    
    if result["exit_code"] != 0:
        print("❌ Zero trust hook failed")
        return False
    
    # Check if secrets were replaced
    if "PLACEHOLDER" in result["stdout"]:
        print("✅ Secrets detected and replaced with placeholders")
    else:
        print("❌ Secrets not detected or replaced")
        return False
    
    # Step 2: Modified tool call should go through claim validation
    try:
        modified_call = json.loads(result["stdout"])
        claim_result = run_hook("response_claim_validator_hook.py", modified_call)
        
        # Should detect "Several MCP servers" and "Many systems" as unverified claims
        if claim_result["exit_code"] == 2:  # Blocked
            print("✅ Unverified claims detected and blocked")
        else:
            print("❌ Claims not properly validated")
            return False
            
    except json.JSONDecodeError:
        print("❌ Invalid JSON output from zero trust hook")
        return False
    
    print("✅ Scenario 1 passed: Full security and verification pipeline working")
    return True

def test_scenario_2_verified_claim_with_safe_content():
    """Test: User makes a verified claim with safe content"""
    print("\n📋 Scenario 2: Verified claim with safe content")
    
    tool_call = {
        "tool_name": "Bash", 
        "tool_input": {
            "command": "echo 'Python is a programming language used for data analysis'"
        }
    }
    
    # Should pass through zero trust (no secrets)
    zt_result = run_hook("examples/hooks/zero_trust_security/hook.py", tool_call)
    if zt_result["exit_code"] != 0:
        print("❌ Zero trust hook failed unexpectedly")
        return False
    
    # Should pass through claim validation (verified claim)
    cv_result = run_hook("response_claim_validator_hook.py", tool_call)
    if cv_result["exit_code"] != 0:
        print("❌ Claim validation failed for verified claim")
        return False
    
    print("✅ Scenario 2 passed: Legitimate content flows through both hooks")
    return True

def test_scenario_3_performance_under_load():
    """Test: Multiple rapid requests to check performance"""
    print("\n📋 Scenario 3: Performance under load")
    
    import time
    
    test_calls = [
        {"tool_name": "Bash", "tool_input": {"command": f"echo 'test command {i}'"}}
        for i in range(10)
    ]
    
    # Test claim validation performance
    start = time.time()
    for call in test_calls:
        result = run_hook("response_claim_validator_hook.py", call)
        if result["exit_code"] != 0:
            print(f"❌ Performance test failed on call {call}")
            return False
    
    cv_duration = time.time() - start
    
    # Test zero trust performance  
    start = time.time()
    for call in test_calls:
        result = run_hook("examples/hooks/zero_trust_security/hook.py", call)
        if result["exit_code"] != 0:
            print(f"❌ Performance test failed on call {call}")
            return False
    
    zt_duration = time.time() - start
    
    print(f"✅ Performance test: CV={cv_duration:.3f}s, ZT={zt_duration:.3f}s for 10 requests")
    
    if cv_duration < 2.0 and zt_duration < 2.0:
        print("✅ Scenario 3 passed: Performance meets requirements")
        return True
    else:
        print("❌ Performance too slow")
        return False

def test_scenario_4_edge_cases():
    """Test: Edge cases and error conditions"""
    print("\n📋 Scenario 4: Edge cases and error handling")
    
    # Test with empty input
    result = run_hook("response_claim_validator_hook.py", {})
    if result["exit_code"] == 0:  # Should allow empty input
        print("✅ Empty input handled gracefully")
    else:
        print("❌ Empty input not handled properly")
        return False
    
    # Test with malformed JSON (simulate via subprocess)
    try:
        process = subprocess.run(
            [sys.executable, "response_claim_validator_hook.py"],
            input="invalid json",
            capture_output=True,
            text=True,
            timeout=5
        )
        
        if process.returncode == 0:  # Should fail-safe
            print("✅ Malformed JSON handled gracefully")
        else:
            print("❌ Malformed JSON not handled properly")
            return False
            
    except Exception as e:
        print(f"❌ Error testing malformed JSON: {e}")
        return False
    
    print("✅ Scenario 4 passed: Edge cases handled correctly")
    return True

def run_hook(hook_path: str, input_data: dict) -> dict:
    """Run a hook with input data and return results"""
    try:
        json_input = json.dumps(input_data)
        
        process = subprocess.run(
            [sys.executable, hook_path],
            input=json_input,
            capture_output=True,
            text=True,
            timeout=5
        )
        
        return {
            "exit_code": process.returncode,
            "stdout": process.stdout,
            "stderr": process.stderr
        }
        
    except Exception as e:
        return {
            "exit_code": -1,
            "stdout": "",
            "stderr": str(e)
        }

def main():
    """Run all real-world test scenarios"""
    print("🌍 Real-World Integration Testing")
    print("=" * 50)
    
    scenarios = [
        test_scenario_1_secret_detection_with_claims,
        test_scenario_2_verified_claim_with_safe_content, 
        test_scenario_3_performance_under_load,
        test_scenario_4_edge_cases
    ]
    
    passed = 0
    total = len(scenarios)
    
    for scenario in scenarios:
        if scenario():
            passed += 1
    
    print("\n" + "=" * 50)
    print("🏁 REAL-WORLD TEST SUMMARY")
    print("=" * 50)
    print(f"Scenarios Passed: {passed}/{total}")
    
    if passed == total:
        print("\n🎉 ALL REAL-WORLD SCENARIOS PASSED!")
        print("✅ System ready for production use")
        print("✅ Handles realistic user interactions")
        print("✅ Performance acceptable under load")
        print("✅ Error handling robust")
    else:
        print(f"\n⚠️  {total - passed} scenarios failed")
        print("❌ System not ready for production")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)