# Claude Code MCP Protocol Fix

Fix for Claude Code MCP (Model Context Protocol) `protocolVersion` validation bug that causes "2 failing MCP servers" messages.

## 🚨 Bug Description

Claude Code v1.0.83 and earlier versions omit the required `protocolVersion` parameter in MCP `initialize` requests, causing MCP servers to fail validation and display persistent error messages.

**Related GitHub Issues:**
- [#1611 - MCP servers failing to initialize](https://github.com/anthropics/claude-code/issues/1611)
- [#768 - Protocol version validation errors](https://github.com/anthropics/claude-code/issues/768)
- [#4793 - MCP initialization failures](https://github.com/anthropics/claude-code/issues/4793)

## 🔧 Fix Components

### Core Fix Files
- `mcp-fix-v2.js` - Main wrapper script that intercepts and patches MCP requests
- `test-json-patching.js` - Unit tests for JSON-RPC message patching logic
- `test_mcp_server.py` - Test MCP server that validates protocolVersion presence
- `prove-fix-works.sh` - Testing script

### CI/CD Testing
- `.github/workflows/test-mcp-fix.yml` - Primary CI workflow
- `.github/workflows/mcp-fix-integration-test.yml` - Integration testing

## 🧪 How It Works

The fix uses Node.js `child_process` interception to:

1. **Intercept MCP Communications**: Wraps Claude Code's child process spawning
2. **Parse JSON-RPC Messages**: Identifies `initialize` method calls
3. **Inject Missing Parameters**: Adds `protocolVersion: "2024-11-05"` if missing
4. **Pass Through Other Messages**: Non-initialize messages remain unchanged

### Technical Implementation

```javascript
// Core patching logic
if (message.method === 'initialize') {
    if (!message.params.protocolVersion) {
        message.params.protocolVersion = '2024-11-05';
        console.error('🔧 [MCP-FIX] Added missing protocolVersion');
    }
}
```

## 🚀 Usage

### Local Installation
```bash
# Make the fix executable
chmod +x mcp-fix-v2.js

# Use instead of claude command
node mcp-fix-v2.js --mcp-config your-config.json --mcp-debug
```

### Testing the Fix
```bash
# Run test script
./prove-fix-works.sh

# Test JSON-RPC patching logic
node test-json-patching.js

# Create test MCP server
python3 test_mcp_server.py
```

## 📊 CI/CD Verification

The GitHub Actions workflows automatically:

1. **Install Claude Code**: Uses latest version from npm
2. **Test Original Bug**: Confirms protocolVersion is missing
3. **Apply Fix**: Tests wrapper injection
4. **Verify Resolution**: Confirms protocolVersion is present
5. **Generate Reports**: Creates detailed test summaries

### Test Results Format
```
✅ Original Claude Code bug confirmed - missing protocolVersion detected
🔧 Fix working - protocolVersion injected  
✅ Wrapper injection confirmed - [MCP-FIX] messages present
```

## 🔍 Verification Steps

1. **JSON-RPC Logic Test**: `test-json-patching.js` validates core patching
2. **MCP Server Test**: Python server detects missing/present protocolVersion
3. **Integration Test**: Full Claude Code execution with MCP configuration
4. **CI Environment**: Automated testing across Node.js versions

## 🎯 Expected Outcomes

### Before Fix (Original Bug)
```
[TEST-MCP] ❌ MISSING protocolVersion - fix failed!
Error: Missing required protocolVersion parameter
```

### After Fix (Working)
```
[TEST-MCP] ✅ Found protocolVersion: 2024-11-05 - fix worked!
🔧 [MCP-FIX] Added missing protocolVersion: 2024-11-05
```

## 🏗️ Architecture

```
Claude Code (Original)
├── Spawns MCP Server Process
├── Sends initialize request (missing protocolVersion) ❌
└── Receives validation error

Claude Code (Fixed with Wrapper)
├── Node.js Wrapper Intercepts
├── Patches JSON-RPC message (adds protocolVersion) ✅
├── Forwards to MCP Server
└── Receives successful response
```

## 🚦 CI Status

[![Test Claude Code MCP Fix](../../actions/workflows/test-mcp-fix.yml/badge.svg)](../../actions/workflows/test-mcp-fix.yml)
[![MCP Fix Integration Test](../../actions/workflows/mcp-fix-integration-test.yml/badge.svg)](../../actions/workflows/mcp-fix-integration-test.yml)

## 🔬 Testing Philosophy

This fix follows the principle: **"Nothing is real unless you've seen it for yourself"**

Every claim about the fix is backed by:
- ✅ Direct testing evidence
- ✅ Automated CI verification  
- ✅ JSON-RPC message inspection
- ✅ MCP server response validation

## 📈 Impact

- **Resolves persistent error messages**: Eliminates "2 failing MCP servers" warnings
- **Enables MCP functionality**: Allows proper MCP server initialization
- **Backward compatible**: Works with existing Claude Code installations
- **Zero modification required**: No changes to original Claude Code binary

## 🤝 Contributing

To test the fix:
1. Fork this repository
2. Push changes to trigger CI
3. Check Actions tab for automated test results
4. View detailed test outputs in workflow artifacts

## 📝 License

This fix is provided as-is for educational and debugging purposes. Use at your own risk.