#!/usr/bin/env python3
"""
Comprehensive Connectivity Validation Test
Tests end-to-end workflow of the verification system components
"""

import json
import subprocess
import sys
import tempfile
import os
from typing import Dict, Any, Tuple

class ConnectivityValidator:
    def __init__(self):
        self.test_results = []
        self.passed = 0
        self.failed = 0
    
    def log_test(self, test_name: str, passed: bool, details: str = ""):
        """Log a test result"""
        status = "✅ PASS" if passed else "❌ FAIL"
        self.test_results.append(f"{status}: {test_name}")
        if details:
            self.test_results.append(f"    {details}")
        
        if passed:
            self.passed += 1
        else:
            self.failed += 1
    
    def test_mcp_server_verification(self) -> bool:
        """Test the MCP server verification engine"""
        print("\n🔍 Testing MCP Server Verification Engine...")
        
        try:
            # Import and test the verifier
            from provenance_mcp_server import ProvenanceVerifier
            verifier = ProvenanceVerifier()
            
            # Test 1: Unverified claim should be rejected
            result = verifier.verify_claim("Several unknown systems exist")
            if not result["assertable"] and result["confidence"] == 0:
                self.log_test("MCP Server - Rejects unverified claims", True)
            else:
                self.log_test("MCP Server - Rejects unverified claims", False, 
                            f"Expected rejection but got assertable={result['assertable']}")
                return False
            
            # Test 2: Verified claim should be accepted
            result = verifier.verify_claim("Several MCP servers exist")
            if result["assertable"] and result["confidence"] >= 80:
                self.log_test("MCP Server - Accepts verified claims", True)
            else:
                self.log_test("MCP Server - Accepts verified claims", False,
                            f"Expected acceptance but got assertable={result['assertable']}")
                return False
            
            return True
            
        except Exception as e:
            self.log_test("MCP Server - Basic functionality", False, str(e))
            return False
    
    def test_claim_validation_hook(self) -> bool:
        """Test the claim validation hook"""
        print("\n🛡️ Testing Claim Validation Hook...")
        
        # Test 1: Should block unverified claims
        test_input = {
            "tool_name": "Bash",
            "tool_input": {
                "command": "echo 'Several mysterious servers exist somewhere'"
            }
        }
        
        result = self._run_hook("response_claim_validator_hook.py", test_input)
        if result["exit_code"] == 2:  # Blocked
            self.log_test("Claim Hook - Blocks unverified claims", True)
        else:
            self.log_test("Claim Hook - Blocks unverified claims", False,
                        f"Expected exit code 2, got {result['exit_code']}")
            return False
        
        # Test 2: Should allow verified claims
        test_input = {
            "tool_name": "Bash", 
            "tool_input": {
                "command": "echo 'Python is a programming language'"
            }
        }
        
        result = self._run_hook("response_claim_validator_hook.py", test_input)
        if result["exit_code"] == 0:  # Allowed
            self.log_test("Claim Hook - Allows verified claims", True)
        else:
            self.log_test("Claim Hook - Allows verified claims", False,
                        f"Expected exit code 0, got {result['exit_code']}")
            return False
        
        return True
    
    def test_zero_trust_security_hook(self) -> bool:
        """Test the zero trust security hook"""
        print("\n🔒 Testing Zero Trust Security Hook...")
        
        # Test with a fake API key
        test_input = {
            "tool_name": "Bash",
            "tool_input": {
                "command": "export API_KEY=sk-1234567890abcdef1234567890abcdef1234567890abcdef"
            }
        }
        
        result = self._run_hook("examples/hooks/zero_trust_security/hook.py", test_input)
        
        # Should succeed (exit 0) but modify the output
        if result["exit_code"] == 0:
            # Check if secret was replaced
            if "PLACEHOLDER" in result["stdout"]:
                self.log_test("Zero Trust - Replaces secrets with placeholders", True)
            else:
                self.log_test("Zero Trust - Replaces secrets with placeholders", False,
                            "Secret not replaced in output")
                return False
        else:
            self.log_test("Zero Trust - Basic functionality", False,
                        f"Hook failed with exit code {result['exit_code']}")
            return False
        
        return True
    
    def test_cross_component_communication(self) -> bool:
        """Test that components can work together"""
        print("\n🔗 Testing Cross-Component Communication...")
        
        # Create a tool call that should trigger both security hooks
        test_input = {
            "tool_name": "Bash",
            "tool_input": {
                "command": "echo 'Several systems use API key sk-1234567890abcdef1234567890abcdef1234567890abcdef'"
            }
        }
        
        # First run through zero trust (should replace secret)
        zero_trust_result = self._run_hook("examples/hooks/zero_trust_security/hook.py", test_input)
        
        if zero_trust_result["exit_code"] != 0:
            self.log_test("Cross-Component - Zero trust processing", False,
                        f"Zero trust hook failed: {zero_trust_result['exit_code']}")
            return False
        
        # Parse the modified output from zero trust
        try:
            modified_input = json.loads(zero_trust_result["stdout"])
        except json.JSONDecodeError:
            self.log_test("Cross-Component - Output parsing", False, "Invalid JSON from zero trust")
            return False
        
        # Run the modified input through claim validation
        claim_result = self._run_hook("response_claim_validator_hook.py", modified_input)
        
        # Should block because "Several systems" is an unverified claim
        if claim_result["exit_code"] == 2:
            self.log_test("Cross-Component - Sequential hook processing", True)
            self.log_test("Cross-Component - Proper claim blocking after secret replacement", True)
        else:
            self.log_test("Cross-Component - Sequential hook processing", False,
                        f"Expected claim blocking, got exit code {claim_result['exit_code']}")
            return False
        
        return True
    
    def test_performance_and_latency(self) -> bool:
        """Test system performance characteristics"""
        print("\n⚡ Testing Performance and Latency...")
        
        import time
        
        # Test response time for claim validation
        start = time.time()
        test_input = {
            "tool_name": "Bash",
            "tool_input": {"command": "echo 'test command'"}
        }
        
        result = self._run_hook("response_claim_validator_hook.py", test_input)
        duration = time.time() - start
        
        if duration < 1.0:  # Should complete within 1 second
            self.log_test("Performance - Claim validation latency", True, 
                        f"Completed in {duration:.3f}s")
        else:
            self.log_test("Performance - Claim validation latency", False,
                        f"Too slow: {duration:.3f}s")
            return False
        
        # Test zero trust performance  
        start = time.time()
        result = self._run_hook("examples/hooks/zero_trust_security/hook.py", test_input)
        duration = time.time() - start
        
        if duration < 1.0:
            self.log_test("Performance - Zero trust latency", True,
                        f"Completed in {duration:.3f}s")
        else:
            self.log_test("Performance - Zero trust latency", False,
                        f"Too slow: {duration:.3f}s")
            return False
        
        return True
    
    def _run_hook(self, hook_path: str, input_data: Dict[str, Any]) -> Dict[str, Any]:
        """Run a hook with input data and return results"""
        try:
            # Convert input to JSON
            json_input = json.dumps(input_data)
            
            # Run the hook
            process = subprocess.run(
                [sys.executable, hook_path],
                input=json_input,
                capture_output=True,
                text=True,
                timeout=5  # 5 second timeout
            )
            
            return {
                "exit_code": process.returncode,
                "stdout": process.stdout,
                "stderr": process.stderr
            }
            
        except subprocess.TimeoutExpired:
            return {
                "exit_code": -1,
                "stdout": "",
                "stderr": "Hook timed out"
            }
        except Exception as e:
            return {
                "exit_code": -1,
                "stdout": "",
                "stderr": str(e)
            }
    
    def run_all_tests(self) -> bool:
        """Run all connectivity tests"""
        print("🚀 Starting Comprehensive Connectivity Validation")
        print("=" * 60)
        
        # Run all test suites
        tests = [
            self.test_mcp_server_verification,
            self.test_claim_validation_hook,
            self.test_zero_trust_security_hook,
            self.test_cross_component_communication,
            self.test_performance_and_latency
        ]
        
        all_passed = True
        for test in tests:
            if not test():
                all_passed = False
        
        # Print summary
        print("\n" + "=" * 60)
        print("📊 CONNECTIVITY VALIDATION SUMMARY")
        print("=" * 60)
        
        for result in self.test_results:
            print(result)
        
        print(f"\nTotal Tests: {self.passed + self.failed}")
        print(f"Passed: {self.passed}")
        print(f"Failed: {self.failed}")
        
        if all_passed:
            print("\n🎉 ALL TESTS PASSED - System is fully connected and operational!")
            print("✅ End-to-end verification workflow is working")
            print("✅ Cross-component communication is established") 
            print("✅ Performance meets requirements")
            print("✅ Security integration is functioning")
        else:
            print("\n⚠️  SOME TESTS FAILED - System has connectivity issues")
            
        return all_passed

def main():
    validator = ConnectivityValidator()
    success = validator.run_all_tests()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()