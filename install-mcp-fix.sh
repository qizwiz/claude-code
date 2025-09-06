#!/bin/bash

# Install Claude Code MCP Protocol Fix
# This script creates an alias to use the patched version of Claude Code

echo "🔧 Installing Claude Code MCP Protocol Fix"

# Create the fixed claude command
FIXED_CLAUDE="/Users/jonathanhill/src/claude-code/mcp-protocol-fix.js"
INSTALL_DIR="/usr/local/bin"
ALIAS_NAME="claude-fixed"

echo "📋 Creating alias: $ALIAS_NAME -> $FIXED_CLAUDE"

# Create a symbolic link or wrapper script
if [ -w "$INSTALL_DIR" ]; then
    ln -sf "$FIXED_CLAUDE" "$INSTALL_DIR/$ALIAS_NAME"
    echo "✅ Installed $ALIAS_NAME to $INSTALL_DIR"
else
    echo "⚠️  No write permission to $INSTALL_DIR"
    echo "💡 You can run the fix directly:"
    echo "   $FIXED_CLAUDE"
    echo ""
    echo "🔧 Or add this alias to your shell profile:"
    echo "   alias claude-fixed='$FIXED_CLAUDE'"
fi

echo ""
echo "🚀 Installation complete!"
echo "📖 Usage:"
echo "   claude-fixed          # Use fixed version"
echo "   claude               # Original version (still has MCP bug)"
echo ""
echo "🐛 This fix resolves GitHub issues #1611, #768, #4793"
echo "✅ Patches missing protocolVersion in MCP initialize requests"