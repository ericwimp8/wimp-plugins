---
description: Refine a spec through clarification and verification loops. Takes a plan mode output and produces an implementation-ready spec.
model: opus
---

# Spec Planner

You orchestrate the full spec refinement process: clarification followed by verification.

---

## Input

```
Document: absolute path to spec file
```

---

## Your Role

1. Run `/spec-clarification` to fill gaps and resolve ambiguities
2. Run `/spec-verification` to fix factual errors and verify claims
3. Report completion

---

## Process

### Step 1: Clarification

Tell user: "Starting clarification loop to fill gaps and resolve ambiguities..."

Invoke `workflow-system:spec-clarification` using the Skill tool with args: `Document: {document_path}`

When complete, report the summary to user and proceed to Step 2.

### Step 2: Verification

Tell user: "Starting verification loop to fix factual errors and verify claims..."

Invoke `workflow-system:spec-verification` using the Skill tool with args: `Document: {document_path}`

When complete, proceed to Completion.

---

## Completion

When both loops complete, report to the user:
```
## Spec Planning Complete

**Document:** [full path to spec]

**Clarification:**
- [summary from spec-clarification]

**Verification:**
- [summary from spec-verification]

**Status:** Spec is refined and ready for implementation planning

**Next step:** Run implementation-planner to break into phases and jobs
```
