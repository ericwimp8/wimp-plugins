# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## Orchestrator ↔ Agent Communication Contract

**MANDATORY**: All orchestrators and agents MUST follow this pattern.

### Why

Prevents orchestrators/agents from adding "helpful" context that causes prompt drift and miscommunication. Both sides agree on exactly what is sent and received.

### Pattern

**Agents** define `## Input` and `## Output` sections:
```
## Input
File: path to the file
Action: what to do

## Output
COMPLETE
Result: [description of outcome]
```

**Orchestrators** define `## Output` and `## Expected Response` sections:
```
## Output
File: path to the file
Action: what to do

## Expected Response
COMPLETE
Result: [description of outcome]
```

Note: The Orchestrator's `## Output` and Agent's `## Input` are identical. The Agent's `## Output` and Orchestrator's `## Expected Response` are identical.

### Example

An orchestrator calling a test-writing agent:

**In `write-tests.md` (orchestrator):**
```markdown
## Output
File: path to file under test
Skills: comma-separated list of skills to use

## Expected Response
COMPLETE
TestFile: [path to generated test file]
Cases: [number of test cases written]
```

**In `tw-write-test.md` (agent):**
```markdown
## Input
File: path to file under test
Skills: comma-separated list of skills to use

## Output
COMPLETE
TestFile: [path to generated test file]
Cases: [number of test cases written]
```

The fields match exactly - verifiable by diffing the two files.

### Rules

1. **Contracts must match** - Orchestrator's `## Output` must match Agent's `## Input` (same fields, same format)
2. **Responses must match** - Agent's `## Output` must match Orchestrator's `## Expected Response` (same fields, same format)
3. **Labeled fields** - Always `Field: value` format
4. **No extra instructions** - Use templates exactly as written
5. **Structured signals** - Return parseable signals (COMPLETE, FAILED, PASS, ISSUES)
6. **Verifiable** - If contracts don't match, the contract is broken

### Optional Fields (Multiple Modes)

When an agent supports multiple modes (e.g., initial vs retry, review vs apply), use **field-presence detection** rather than explicit mode labels.

**Why:** The orchestrator sends fields, not mode labels. The agent detects which mode it's in by checking which fields are present. This keeps contracts simple and matchable.

**Pattern:**

```markdown
## Input

```
RequiredField1: description
RequiredField2: description
```

**Optional fields (for [mode name]):**
```
OptionalField1: description
OptionalField2: description
```

## Detecting Mode

If only required fields present → Mode A
If optional fields also present → Mode B
```

**Example - deep-drill agent:**

```markdown
## Input

```
Phase: [full phase section from spec]
Spec path: absolute path to spec file
Previous phase plans: comma-separated paths, or "none"
Output path: path for the plan file
```

**Optional fields (for retry after slag-check issues):**
```
Feedback: issues from slag-check audit
Previous attempt: path to plan file that failed audit
```

## Detecting Mode

If only base fields present → Initial mode (fresh research)
If Feedback/Previous attempt present → Fix mode (address issues)
```

**Orchestrator sends:**
- Initial: just the base 4 fields
- Retry: base 4 fields + Feedback + Previous attempt

**Agent detects mode** by checking if `Feedback:` is present - no mode label needed.

**Key principle:** Both sides document the same fields. The orchestrator notes "add these fields when retrying" and the agent notes "if these fields present, I'm in retry mode."
