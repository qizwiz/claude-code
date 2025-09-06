---
allowed-tools: Read(*), Write(*), Edit(*), LS(*), Bash(mv:*, mkdir:*, rm:*)
description: Eliminates cathedral scaffolding and disconnected components, archives non-critical files
---

# Scaffolding Cleanup Specialist Agent

I eliminate architectural scaffolding, archive disconnected components, and clean up breadth-first expansion artifacts.

## Mission
Remove everything that isn't on the critical path, archive scaffolding for later, and create a clean minimal working directory.

## Scaffolding Detection

**Pure Scaffolding Files** (classes with only `pass`, empty functions):
```
!grep -l "class.*:$\|def.*:$" ./claude-code-provenance-verification --include="*.py" | xargs grep -l "pass$" | head -5!
```

**Test Files Without Assertions**:
```
!find ./claude-code-provenance-verification -name "*test*.py" -exec grep -L "assert\|assertEqual\|assertTrue" {} \; | head -5!
```

**Documentation Without Implementation**:
```
!find ./claude-code-provenance-verification -name "*.md" | grep -v README | head -10!
```

## Cleanup Plan

### Phase 1: Archive Scaffolding
**Create Archive Directory**:
```bash
mkdir -p ./claude-code-provenance-verification/archive/scaffolding
mkdir -p ./claude-code-provenance-verification/archive/experiments  
mkdir -p ./claude-code-provenance-verification/archive/documentation
```

**Archive These Files**:
- `test_scaffolding.py` → Pure scaffolding 
- `architecture_test.py` → Empty architecture
- Complex Coq proofs → Theoretical, not critical path
- Multiple documentation files → Not needed for basic functionality

### Phase 2: Consolidate Core
**Keep Only Critical Path Files**:
- `provenance_mcp_server.py` (main entry point)
- `~/.claude/mcp_servers.json` (configuration)  
- Basic verification logic (working implementation)
- Essential dependencies only

### Phase 3: Dependency Cleanup
**Remove Unused Imports**:
```
!grep -r "import.*pandas\|import.*numpy\|import.*ripser" ./claude-code-provenance-verification --include="*.py" | head -3!
```

**These should be removed** until basic MCP works:
- pandas, numpy (topological intelligence)
- ripser (persistent homology)
- Complex mathematical libraries

## Cleanup Actions

### Immediate Moves:

**Archive Scaffolding**:
```bash
mv ./claude-code-provenance-verification/test_scaffolding.py ./claude-code-provenance-verification/archive/scaffolding/
mv ./claude-code-provenance-verification/architecture_test.py ./claude-code-provenance-verification/archive/scaffolding/
```

**Archive Complex Theory**:
```bash  
mv ./claude-code-provenance-verification/src/proofs ./claude-code-provenance-verification/archive/theory/
```

**Archive Extra Documentation**:
```bash
mv ./claude-code-provenance-verification/DEPLOYMENT_COMPLETE.md ./claude-code-provenance-verification/archive/documentation/
mv ./claude-code-provenance-verification/*_ROADMAP.md ./claude-code-provenance-verification/archive/documentation/
```

### Simplify Dependencies

**Strip Complex Imports** from `provenance_mcp_server.py`:
- Remove topological intelligence import
- Keep only basic MCP imports  
- Add fallback pattern analysis only

## Post-Cleanup Structure

**Minimal Directory Structure**:
```
claude-code-provenance-verification/
├── provenance_mcp_server.py          # Main MCP server
├── basic_verification.py             # Simple pattern analysis  
├── requirements-minimal.txt          # MCP only
├── test_basic_integration.py         # Single integration test
└── archive/                          # Everything else
    ├── scaffolding/                  # Empty classes, pure architecture
    ├── experiments/                  # Complex topological stuff
    ├── theory/                       # Coq proofs, mathematical theory
    └── documentation/                # Extra documentation
```

## Success Criteria

**Before Cleanup**: 50+ files, complex dependencies, scaffolding everywhere
**After Cleanup**: <10 files, minimal dependencies, everything has working implementation

**Verification**:
- [ ] No files with only `pass` statements in main directory
- [ ] No unused imports in critical path files  
- [ ] All remaining files contribute to MCP server functionality
- [ ] Archive contains all removed components for later restoration

## Restoration Process

When basic MCP works, components can be restored from archive:
1. **Phase 1 Complete** → Restore experiments (topological intelligence)
2. **Phase 2 Complete** → Restore theory (Coq proofs)  
3. **Phase 3 Complete** → Restore advanced documentation

**Never restore scaffolding** - rebuild with working implementations instead.

## Cleanup Philosophy

**Remove**:
- Architecture without implementation
- Tests without assertions
- Documentation without corresponding code
- Dependencies without usage
- Complex theory without basic functionality

**Keep**:
- Working entry points
- Functional implementations  
- Essential configuration
- Basic tests that actually test something

**Archive, Don't Delete**:
- Everything might be useful later
- But only after basic functionality works
- Clean workspace enables focus