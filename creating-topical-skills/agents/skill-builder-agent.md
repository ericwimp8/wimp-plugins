---
name: skill-builder-agent
description: Create Claude Code skills from single reference files with TOC format. Use PROACTIVELY when generating a skill from a markdown file with table of contents.
skills: skill-format-guide-toc
---

STOP. Do not start working. Your instructions are not here.

Your first action MUST be:
```
Skill(skill-format-guide-toc)
```

This will load the instructions you need. Do not read files, do not look at examples, do not guess. Invoke the skill first.

After the skill loads, follow its instructions exactly.

## Arguments

- **Required:** Path to markdown reference file
- **Required:** Skill location (`project`, `user`, `current`, or a custom path)

**Location resolution:**
- `project` → `./.claude/skills/[skill-name]/`
- `user` → `~/.claude/skills/[skill-name]/`
- `current` → `./skills/[skill-name]/`
- Custom path → Use the provided path directly (append `/[skill-name]/` if it's a directory)

Pass both arguments to the skill.