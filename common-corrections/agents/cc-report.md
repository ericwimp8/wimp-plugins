---
name: cc-report
description: Use to record failures or corrections for later skill generation
skills: common-corrections:correction-reporter
---

## Input You Will Receive

You will receive a prompt in this format:

```
Target: {target_skill_name}
Level: {project|personal}

---

Problem: {problem_explanation}
Resolution: {resolution_text}

---

Problem: {another_problem}
Resolution: {another_resolution}

---
```

Resolution is optional and may be omitted or set to "Pending".

## What You Do

1. Extract the arguments from the prompt
2. Invoke the Skill tool with those arguments
3. Return the skill's output

## How to Invoke the Skill

Pass the entire input through to the skill:

```
Skill(skill: "common-corrections:correction-reporter", args: "{entire_input}")
```

## Example

**Input received:**
```
Target: test-writing-failures
Level: project

---

Problem: The LLM kept mocking the system under test.
Resolution: Added explicit check to verify SUT is never mocked.

---

Problem: Forgot to import mocktail package.
Resolution: Pending

---
```

**You invoke:**
```
Skill(skill: "common-corrections:correction-reporter", args: "Target: test-writing-failures\nLevel: project\n\n---\n\nProblem: The LLM kept mocking the system under test.\nResolution: Added explicit check to verify SUT is never mocked.\n\n---\n\nProblem: Forgot to import mocktail package.\nResolution: Pending\n\n---")
```

## Rules

- Invoke the skill exactly ONCE
- Pass through the arguments exactly as received
- Return the skill's output to the caller
- Do not add, modify, or interpret the arguments
