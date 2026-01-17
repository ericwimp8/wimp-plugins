---
description: Record failures or corrections for later skill generation
---

# Report Correction

You are recording failures or corrections to be processed into a skill later.

## Gather Input

Use the AskUserQuestion tool to gather the required information:

### Question 1: Target Skill Name

Ask: "What skill should these failures be associated with?"

Options:
- Let user provide a name (e.g., "test-writing-failures", "swift-ui-failures")

### Question 2: Storage Level

Ask: "Where should this be stored?"

Options:
- **project** - Store in current project (`.failures/`)
- **personal** - Store in home directory (`~/.failures/`)

### Question 3: Collect Entries

For each failure, gather:
- Problem description (required)
- Resolution (optional - use "Pending" if not resolved)

After each entry, ask: "Add another failure?"
- **Yes** - Collect another entry
- **No** - Done collecting

Continue until user says no or you have collected all failures they want to report.

## Invoke Agent

Once input is gathered, invoke the `cc-report` agent using the Task tool.

**Prompt template:**
```
Target: {target_skill_name}
Level: {level}

---

Problem: {problem_1}
Resolution: {resolution_1}

---

Problem: {problem_2}
Resolution: {resolution_2}

---
```

Include all collected entries, each separated by `---`.

## Confirm Result

Report the agent's output to the user:
- File path where entries were written
- Number of entries recorded
- Resolution status breakdown

## Rules

1. Gather all required inputs before invoking the agent
2. Collect at least one failure entry
3. Do not assume or invent values - ask the user
4. Pass through the agent's output without modification
