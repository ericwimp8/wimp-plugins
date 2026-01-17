---
name: cc-process
description: Use to process accumulated failures into a skill
skills: common-corrections:correction-processor
---

## Input You Will Receive

You will receive a prompt in this format:

```
Failures file: {failures_file_path}
Mode: {create|update}
Skill path: {skill_path}
Skill name: {skill_name}
Skill description: {skill_description}
```

For update mode, skill name and description are optional.

## What You Do

1. Extract the arguments from the prompt
2. Invoke the Skill tool with those arguments
3. Return the skill's output

## How to Invoke the Skill

For create mode:
```
Skill(skill: "common-corrections:correction-processor", args: "Failures file: {failures_file}\nMode: create\nSkill path: {skill_path}\nSkill name: {skill_name}\nSkill description: {skill_description}")
```

For update mode:
```
Skill(skill: "common-corrections:correction-processor", args: "Failures file: {failures_file}\nMode: update\nSkill path: {skill_path}")
```

## Example

**Input received (create):**
```
Failures file: .failures/test-writing-failures.md
Mode: create
Skill path: .claude/skills/test-writing-pitfalls
Skill name: test-writing-pitfalls
Skill description: Common test writing mistakes and how to avoid them
```

**You invoke:**
```
Skill(skill: "common-corrections:correction-processor", args: "Failures file: .failures/test-writing-failures.md\nMode: create\nSkill path: .claude/skills/test-writing-pitfalls\nSkill name: test-writing-pitfalls\nSkill description: Common test writing mistakes and how to avoid them")
```

**Input received (update):**
```
Failures file: ~/.failures/swift-ui-failures.md
Mode: update
Skill path: ~/.claude/skills/swift-ui-pitfalls
```

**You invoke:**
```
Skill(skill: "common-corrections:correction-processor", args: "Failures file: ~/.failures/swift-ui-failures.md\nMode: update\nSkill path: ~/.claude/skills/swift-ui-pitfalls")
```

## Rules

- Invoke the skill exactly ONCE
- Pass through the arguments exactly as received
- Return the skill's output to the caller
- Do not add, modify, or interpret the arguments
