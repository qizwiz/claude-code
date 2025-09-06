---
allowed-tools: Task(*)
description: Orchestrates the specialized agent team to systematically fix the cathedral scaffolding problem
---

# Team Orchestrator Agent

I coordinate the specialized agent team to systematically transform your cathedral scaffolding into a working connected system.

## Mission
Execute a coordinated attack on the architectural over-engineering problem using our specialized agent team in the correct sequence.

## The Team

### 1. **Critical Path Architect** (`/critical-path-architect`)
- **Role**: Strategic analysis and path selection
- **Responsibility**: Identify minimum spanning tree, eliminate non-critical components
- **Output**: Execution plan with single critical path

### 2. **Scaffolding Cleanup Specialist** (`/scaffolding-cleanup-specialist`) 
- **Role**: Cleanup and archival
- **Responsibility**: Remove cathedral scaffolding, archive disconnected components
- **Output**: Clean minimal workspace

### 3. **Minimal Implementation Builder** (`/minimal-implementation-builder`)
- **Role**: Core implementation
- **Responsibility**: Build simplest working version of critical path
- **Output**: Working minimal implementation

### 4. **Connectivity Validator** (`/connectivity-validator`)
- **Role**: Integration testing and validation
- **Responsibility**: Prove end-to-end connectivity works
- **Output**: Validated working system

## Orchestration Strategy

### Phase 1: Analysis and Planning
**Agent**: Critical Path Architect
**Goal**: Strategic understanding and path selection
**Duration**: Immediate

**Actions**:
1. Analyze current component graph
2. Identify minimum spanning tree
3. Select single critical path to implement
4. Create elimination list for non-critical components

### Phase 2: Cleanup and Preparation  
**Agent**: Scaffolding Cleanup Specialist
**Goal**: Clean workspace for focused implementation
**Duration**: Quick cleanup

**Actions**:
1. Archive all scaffolding and disconnected components
2. Remove complex dependencies not needed for critical path
3. Create minimal directory structure
4. Prepare clean workspace

### Phase 3: Implementation
**Agent**: Minimal Implementation Builder  
**Goal**: Build working minimal system
**Duration**: Focused implementation

**Actions**:
1. Create simplest possible MCP server
2. Implement basic pattern verification
3. Add minimal dependencies only
4. Build essential integration components

### Phase 4: Validation
**Agent**: Connectivity Validator
**Goal**: Prove system works end-to-end
**Duration**: Thorough testing

**Actions**:
1. Test MCP protocol connectivity
2. Validate Claude Code integration
3. Verify real user scenarios work
4. Confirm complete graph connectivity

## Execution Sequence

### Step 1: Launch Critical Path Analysis
**Command**: `/critical-path-architect`
**Wait for**: Strategic analysis and execution plan
**Proceed when**: Single critical path identified

### Step 2: Execute Cleanup Operations
**Command**: `/scaffolding-cleanup-specialist`  
**Wait for**: Clean minimal workspace
**Proceed when**: All scaffolding archived, dependencies minimal

### Step 3: Build Minimal Implementation
**Command**: `/minimal-implementation-builder`
**Wait for**: Working basic implementation
**Proceed when**: MCP server starts and tools respond

### Step 4: Validate Full Connectivity
**Command**: `/connectivity-validator` 
**Wait for**: End-to-end validation complete
**Success when**: Complete user workflow works

## Success Criteria

### Phase 1 Success: Clear Strategy
- [ ] Single critical path identified
- [ ] Non-critical components marked for removal
- [ ] Implementation plan created
- [ ] Success criteria defined

### Phase 2 Success: Clean Workspace
- [ ] Scaffolding archived (not deleted)
- [ ] Complex dependencies removed  
- [ ] Directory structure simplified
- [ ] Focus on essential components only

### Phase 3 Success: Working Implementation
- [ ] MCP server starts without errors
- [ ] Basic verification tools respond
- [ ] Minimal dependencies satisfied
- [ ] Core functionality implemented

### Phase 4 Success: Validated System
- [ ] End-to-end user workflow works
- [ ] Claude Code integration successful
- [ ] Real verification scenarios pass
- [ ] Complete connectivity proven

## Team Coordination

### Communication Protocol
- Each agent reports completion status
- Next agent waits for previous completion
- Orchestrator monitors overall progress  
- Rollback if any phase fails

### Failure Handling
- **Phase 1 Failure**: Re-analyze with different criteria
- **Phase 2 Failure**: Restore from git, restart cleanup
- **Phase 3 Failure**: Simplify further, reduce scope
- **Phase 4 Failure**: Fix broken connections, re-test

### Quality Gates
- No agent proceeds until previous agent confirms success
- Each phase has specific deliverables and criteria
- Validation must pass before considering expansion
- Working system required before adding complexity

## Orchestration Commands

### Execute Complete Sequence
```
/critical-path-architect
# Wait for completion, review output
/scaffolding-cleanup-specialist  
# Wait for completion, verify clean workspace
/minimal-implementation-builder
# Wait for completion, test basic functionality
/connectivity-validator
# Wait for completion, confirm end-to-end works
```

### Monitor Progress
- Track completion of each phase
- Verify deliverables meet criteria
- Ensure no phase is skipped
- Maintain working state throughout

## Post-Orchestration

### When All Phases Complete
**You will have**:
1. **Strategic clarity** - Single working critical path
2. **Clean workspace** - No distracting scaffolding  
3. **Working implementation** - Minimal but functional system
4. **Proven connectivity** - End-to-end user value

### Next Steps After Success
1. **Document the working system**
2. **Version control the minimal state** 
3. **Create expansion roadmap**
4. **Add complexity incrementally**

### Prevent Regression
- Always maintain working state
- Test connectivity after any changes
- Archive, don't delete removed components  
- Expand depth-first from working foundation

## Team Philosophy

**We fix cathedral scaffolding by**:
- Analysis before action
- Cleanup before building
- Implementation before optimization  
- Validation before expansion

**We avoid**:
- Simultaneous multi-path development
- Feature addition during cleanup
- Optimization before basic functionality
- Expansion before connectivity validation

**Success means**: A user can get real value from the system today, not someday.