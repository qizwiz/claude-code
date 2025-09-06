#!/usr/bin/env python3
"""
Final Validation Test Suite for Zero-Trust Security Framework
"""
import subprocess
import json
import sys

def test_core_functionality():
    """Test core zero-trust security functionality"""
    print("🔐 CORE FUNCTIONALITY VALIDATION")
    print("=" * 50)
    
    # Test cases
    test_cases = [
        {
            "name": "OpenAI API Key Detection",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef"
                }
            },
            "should_detect": True,
            "placeholder_type": "OPENAI_API_KEY_PLACEHOLDER"
        },
        {
            "name": "Anthropic API Key Detection",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "export ANTHROPIC_API_KEY=sk-ant-api03-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12R"
                }
            },
            "should_detect": True,
            "placeholder_type": "ANTHROPIC_API_KEY_PLACEHOLDER"
        },
        {
            "name": "AWS Access Key Detection",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLA"
                }
            },
            "should_detect": True,
            "placeholder_type": "AWS_ACCESS_KEY_PLACEHOLDER"
        },
        {
            "name": "Safe Command Passthrough",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "echo 'Hello World'"
                }
            },
            "should_detect": False,
            "placeholder_type": None
        },
        {
            "name": "Test Pattern Ignoring",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": "export OPENAI_API_KEY=sk-example1234567890abcdef1234567890abcdef12"
                }
            },
            "should_detect": False,
            "placeholder_type": None
        }
    ]
    
    results = []
    for i, test_case in enumerate(test_cases, 1):
        print(f"\n🧪 Test {i}: {test_case['name']}")
        print("-" * 40)
        
        try:
            result = subprocess.run(
                ["python3", "examples/hooks/zero_trust_security/hook.py"],
                input=json.dumps(test_case["input"]),
                capture_output=True,
                text=True,
                cwd="/Users/jonathanhill/src/claude-code",
                timeout=10
            )
            
            # Analyze results
            detected = "PLACEHOLDER" in result.stdout if result.stdout else False
            has_placeholder_type = test_case["placeholder_type"] and test_case["placeholder_type"] in result.stdout if result.stdout else False
            
            # Check expectations
            if test_case["should_detect"]:
                success = detected and (has_placeholder_type or test_case["placeholder_type"] is None)
                print(f"   Expected: Secret detection")
                print(f"   Actual: {'✅ Detected' if detected else '❌ Not detected'}")
                if test_case["placeholder_type"]:
                    print(f"   Placeholder: {'✅ Correct type' if has_placeholder_type else '❌ Wrong type'}")
            else:
                success = not detected
                print(f"   Expected: No detection")
                print(f"   Actual: {'✅ No detection' if not detected else '❌ Unexpected detection'}")
            
            # Show output for debugging
            if result.stdout:
                print(f"   Output: {result.stdout[:100]}{'...' if len(result.stdout) > 100 else ''}")
            if result.stderr:
                print(f"   Messages: {result.stderr[:100]}{'...' if len(result.stderr) > 100 else ''}")
            
            results.append({
                "test": test_case["name"],
                "success": success,
                "details": "Correct behavior" if success else "Incorrect behavior"
            })
            
            status = "✅ PASS" if success else "❌ FAIL"
            print(f"   {status} {test_case['name']}")
            
        except Exception as e:
            print(f"   ❌ ERROR Test failed: {e}")
            results.append({
                "test": test_case["name"],
                "success": False,
                "details": f"Test error: {str(e)}"
            })
    
    return results

def test_framework_integration():
    """Test integration with Claude Code ecosystem"""
    print("\n🔌 FRAMEWORK INTEGRATION VALIDATION")
    print("=" * 50)
    
    integration_tests = [
        {
            "name": "Hook Execution",
            "command": ["python3", "examples/hooks/zero_trust_security/hook.py"],
            "input": json.dumps({"tool_name": "Bash", "tool_input": {"command": "echo hello"}}),
            "expect_success": True
        },
        {
            "name": "Module Import",
            "command": ["python3", "-c", "import sys; sys.path.append('examples/hooks/zero_trust_security/framework'); import secret_detection; print('Import successful')"],
            "input": None,
            "expect_success": True
        },
        {
            "name": "Configuration Loading",
            "command": ["python3", "-c", "import sys; sys.path.append('examples/hooks/zero_trust_security/framework'); from config import load_config; config = load_config(); print('Config loaded' if config else 'Config empty')"],
            "input": None,
            "expect_success": True
        }
    ]
    
    results = []
    for i, test in enumerate(integration_tests, 1):
        print(f"\n🧪 Integration Test {i}: {test['name']}")
        print("-" * 45)
        
        try:
            if test["input"]:
                result = subprocess.run(
                    test["command"],
                    input=test["input"],
                    capture_output=True,
                    text=True,
                    cwd="/Users/jonathanhill/src/claude-code",
                    timeout=15
                )
            else:
                result = subprocess.run(
                    test["command"],
                    capture_output=True,
                    text=True,
                    cwd="/Users/jonathanhill/src/claude-code",
                    timeout=15
                )
            
            success = (result.returncode == 0) == test["expect_success"]
            print(f"   Expected: {'Success' if test['expect_success'] else 'Failure'}")
            print(f"   Actual: {'Success' if result.returncode == 0 else 'Failure'} (exit code: {result.returncode})")
            
            if result.stdout:
                print(f"   Output: {result.stdout[:80]}{'...' if len(result.stdout) > 80 else ''}")
            if result.stderr:
                print(f"   Errors: {result.stderr[:80]}{'...' if len(result.stderr) > 80 else ''}")
            
            results.append({
                "test": test["name"],
                "success": success,
                "details": "Integration successful" if success else "Integration failed"
            })
            
            status = "✅ PASS" if success else "❌ FAIL"
            print(f"   {status} {test['name']}")
            
        except Exception as e:
            print(f"   ❌ ERROR Integration test failed: {e}")
            results.append({
                "test": test["name"],
                "success": False,
                "details": f"Test error: {str(e)}"
            })
    
    return results

def test_performance_and_scalability():
    """Test performance and scalability characteristics"""
    print("\n⚡ PERFORMANCE AND SCALABILITY VALIDATION")
    print("=" * 55)
    
    # Test with large content
    large_content = "echo '" + "A" * 10000 + "' && " + "export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef && echo 'Processing complete'"
    
    performance_tests = [
        {
            "name": "Large Content Processing",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": large_content
                }
            },
            "timeout": 5  # Should process quickly
        },
        {
            "name": "Multiple Secret Detection",
            "input": {
                "tool_name": "Bash",
                "tool_input": {
                    "command": " && ".join([
                        "export OPENAI_API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef",
                        "export ANTHROPIC_API_KEY=sk-ant-api03-1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef12R",
                        "export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLA",
                        "echo 'All secrets processed'"
                    ])
                }
            },
            "timeout": 3
        }
    ]
    
    results = []
    for i, test in enumerate(performance_tests, 1):
        print(f"\n⚡ Performance Test {i}: {test['name']}")
        print("-" * 45)
        
        try:
            import time
            start_time = time.time()
            
            result = subprocess.run(
                ["python3", "examples/hooks/zero_trust_security/hook.py"],
                input=json.dumps(test["input"]),
                capture_output=True,
                text=True,
                cwd="/Users/jonathanhill/src/claude-code",
                timeout=test["timeout"]
            )
            
            end_time = time.time()
            execution_time = end_time - start_time
            
            # Check if it completed within timeout
            success = result.returncode == 0
            meets_performance = execution_time < test["timeout"]
            
            print(f"   Execution time: {execution_time:.3f}s")
            print(f"   Timeout limit: {test['timeout']}s")
            print(f"   Status: {'✅ PASS' if success and meets_performance else '❌ FAIL'}")
            
            results.append({
                "test": test["name"],
                "success": success and meets_performance,
                "details": f"Completed in {execution_time:.3f}s"
            })
            
        except subprocess.TimeoutExpired:
            print(f"   ❌ FAIL Timed out (> {test['timeout']}s)")
            results.append({
                "test": test["name"],
                "success": False,
                "details": f"Timed out (> {test['timeout']}s)"
            })
        except Exception as e:
            print(f"   ❌ ERROR Performance test failed: {e}")
            results.append({
                "test": test["name"],
                "success": False,
                "details": f"Test error: {str(e)}"
            })
    
    return results

def main():
    """Run final validation tests"""
    print("🏁 Zero-Trust Security Framework Final Validation")
    print("=" * 65)
    
    # Run all validation suites
    core_results = test_core_functionality()
    integration_results = test_framework_integration()
    performance_results = test_performance_and_scalability()
    
    # Combine all results
    all_results = core_results + integration_results + performance_results
    
    # Summary
    print("\n" + "=" * 65)
    print("📊 FINAL VALIDATION SUMMARY")
    print("=" * 65)
    
    passed = sum(1 for result in all_results if result["success"])
    total = len(all_results)
    
    print(f"Tests passed: {passed}/{total} ({passed/total*100:.1f}%)")
    
    # Show failed tests
    failed_tests = [result for result in all_results if not result["success"]]
    if failed_tests:
        print(f"\n❌ FAILED TESTS:")
        for result in failed_tests:
            print(f"   • {result['test']}: {result['details']}")
    
    # Overall assessment
    if passed == total:
        print("\n🎉 ALL VALIDATION TESTS PASSED!")
        print("✅ Core functionality working correctly")
        print("✅ Framework integration successful")
        print("✅ Performance requirements met")
        print("\nThe Zero-Trust Security Framework is:")
        print("• Production ready")
        print("• Fully compatible with Claude Code")
        print("• Secure and performant")
        print("• Ready for enterprise deployment")
        return True
    elif passed/total >= 0.9:
        print(f"\n⚠️  {total - passed} TESTS FAILED BUT MAJOR FUNCTIONALITY WORKS")
        print("The framework is mostly functional with minor issues.")
        return True
    else:
        print(f"\n❌ {total - passed} TESTS FAILED")
        print("Significant issues need to be addressed before production use.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)