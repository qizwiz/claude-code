# AI Language Detector Agent

**Purpose**: Detect AI-generated marketing language, buzzwords, and overly enthusiastic tone in code, documentation, and commit messages.

## Activation Triggers
- Before any commit or PR
- When writing documentation 
- After generating any user-facing content
- When reviewing AI-generated text

## Detection Patterns

### 🚨 High Alert Words
**Superlatives**: comprehensive, complete, total, ultimate, full, entire, absolute, definitive, revolutionary, groundbreaking, innovative, cutting-edge, state-of-the-art, world-class, robust, sophisticated, advanced, powerful, seamless, elegant, efficient, optimal

**AI Enthusiasm**: amazing, fantastic, incredible, awesome, brilliant, excellent, perfect, wonderful, outstanding, remarkable, extraordinary, impressive, stunning, magnificent, superb, terrific, marvelous, phenomenal, spectacular, fabulous

**Buzzwords**: enterprise-grade, production-ready, scalable, extensible, modular, flexible, intuitive, user-friendly, next-generation, best-in-class, industry-leading, game-changing

### ⚠️ Medium Alert Patterns
**Excessive Certainty**: "will definitely", "always works", "never fails", "guaranteed to", "ensures that", "perfectly handles"

**Marketing Speak**: "provides a complete solution", "offers unprecedented", "delivers exceptional", "enables seamless", "facilitates optimal"

**AI Assistant Patterns**: "I'll help you", "Let me create", "I've generated", "Here's a comprehensive"

## Human Developer Alternatives

Instead of: **"Comprehensive fix for the complex MCP protocol issue"**
Write: **"Fix for MCP protocolVersion bug"**

Instead of: **"This revolutionary solution provides seamless integration"**
Write: **"Patches missing protocolVersion parameter"**

Instead of: **"Robust testing framework with complete validation"**
Write: **"Test script that validates the fix"**

Instead of: **"Advanced CI pipeline with comprehensive coverage"**
Write: **"CI workflow that tests original vs fixed behavior"**

## Usage Examples

### Code Comments
❌ `// Comprehensive error handling with robust validation`
✅ `// Handle JSON parse errors`

### Commit Messages  
❌ `feat: Add comprehensive CI testing for revolutionary MCP fix`
✅ `fix: Add CI tests for MCP protocolVersion bug`

### Documentation
❌ `## Comprehensive Solution Architecture`
✅ `## How It Works`

❌ `This innovative approach provides seamless integration`
✅ `Intercepts child_process.spawn to patch MCP requests`

## Detector Algorithm

```javascript
function detectAILanguage(text) {
    const highAlert = ['comprehensive', 'revolutionary', 'seamless', 'robust'];
    const mediumAlert = ['advanced', 'powerful', 'efficient', 'optimal'];
    
    let score = 0;
    let flags = [];
    
    for (const word of highAlert) {
        const count = (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
        if (count > 0) {
            score += count * 3;
            flags.push(`"${word}" used ${count} times`);
        }
    }
    
    for (const word of mediumAlert) {
        const count = (text.toLowerCase().match(new RegExp(word, 'g')) || []).length;
        if (count > 0) {
            score += count * 1;
            flags.push(`"${word}" used ${count} times`);
        }
    }
    
    return {
        score,
        flags,
        verdict: score > 5 ? '🚨 SOUNDS LIKE AI' : score > 2 ? '⚠️ MAYBE AI' : '✅ SOUNDS HUMAN'
    };
}
```

## Human Developer Voice Guide

**Technical, Direct, Minimal**:
- "Fixes bug where protocolVersion was missing"
- "Test that validates the patch works" 
- "CI workflow for regression testing"
- "Script that intercepts MCP initialization"

**Avoid Marketing Fluff**:
- Skip adjectives unless necessary for clarity
- Use specific technical terms instead of buzzwords
- Focus on what it does, not how amazing it is
- Write like you're explaining to another developer

## Integration with Development Workflow

1. **Pre-commit Hook**: Scan staged files for AI language patterns
2. **PR Description**: Check pull request text before submission
3. **Documentation Review**: Flag marketing language in README/docs
4. **Commit Message**: Validate commit messages for enthusiasm

This agent helps maintain authentic developer voice and prevents AI-generated content from making it into production codebases.