# Claude Code Plugin System: Complete Technical Reference

Claude Code's plugin architecture enables extensibility through **five core extension mechanisms**: plugins, hooks, MCP servers, slash commands, and skills. Plugins bundle these components for distribution via marketplaces, while hooks provide deterministic lifecycle control through shell commands executed at specific events.

## Plugin Architecture and Directory Structure

Plugins extend Claude Code with custom commands, agents, hooks, Skills, and MCP servers. A properly structured plugin follows this layout:

```
plugin-name/
├── .claude-plugin/           # Metadata directory (ONLY plugin.json goes here)
│   └── plugin.json          # Required: plugin manifest
├── commands/                 # Slash commands (Markdown files)
│   └── review.md
├── agents/                   # Specialized subagents (Markdown files)
│   └── security-reviewer.md
├── skills/                   # Agent Skills (auto-invoked context)
│   └── code-reviewer/
│       └── SKILL.md
├── hooks/                    # Event handlers
│   └── hooks.json
├── .mcp.json                # MCP server definitions
└── README.md
```

**Critical**: All component directories (`commands/`, `agents/`, `skills/`, `hooks/`) must be placed at the plugin root—NOT inside `.claude-plugin/`. Only `plugin.json` belongs in `.claude-plugin/`.

## The plugin.json Manifest Schema

```json
{
  "name": "deployment-tools",
  "version": "1.2.0",
  "description": "Automated deployment workflows",
  "author": {
    "name": "Author Name",
    "email": "author@example.com",
    "url": "https://github.com/author"
  },
  "homepage": "https://docs.example.com/plugin",
  "repository": "https://github.com/author/plugin",
  "license": "MIT",
  "keywords": ["deployment", "devops", "automation"],
  "commands": ["./custom/commands/special.md"],
  "agents": "./custom/agents/",
  "skills": "./custom/skills/",
  "hooks": "./config/hooks.json",
  "mcpServers": "./mcp-config.json"
}
```

Only `name` is required (kebab-case, no spaces). All path fields are optional and supplement default directory locations. Plugin commands receive namespacing: `/plugin-name:command-name`.

### Path Behavior Rules

Custom paths **supplement** default directories—they don't replace them. If `commands/` exists, it loads in addition to custom command paths. All paths must be relative to plugin root and start with `./`.

## Hooks System: Lifecycle Control

Hooks execute shell commands at specific points in Claude Code's lifecycle. The system supports **10 hook events**:

| Event | Trigger | Can Modify Behavior |
|-------|---------|---------------------|
| `PreToolUse` | Before tool execution | Yes—block, allow, or modify inputs |
| `PostToolUse` | After tool completion | Yes—validate and provide feedback |
| `PermissionRequest` | Permission dialog shown | Yes—programmatically allow/deny |
| `UserPromptSubmit` | User submits prompt | Yes—inject context |
| `Notification` | Claude sends notifications | No |
| `Stop` | Main agent finishes | Yes—prevent stopping |
| `SubagentStop` | Subagent finishes | Yes |
| `PreCompact` | Before context compaction | No |
| `SessionStart` | Session starts/resumes | No—but can load environment |
| `SessionEnd` | Session ends | No |

### Hook Configuration

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write(*.py)",
        "hooks": [
          {
            "type": "command",
            "command": "python -m black \"$(jq -r '.tool_input.file_path')\""
          }
        ]
      }
    ]
  }
}
```

**Matcher patterns**: exact matches (`Write`), pipe-separated alternatives (`Edit|Write|Bash`), wildcards (`*` or `""`), MCP tool patterns (`mcp__github__*`).

### Hook Input/Output

Hooks receive JSON via stdin:

```json
{
  "session_id": "abc123",
  "transcript_path": "/Users/.../session.jsonl",
  "cwd": "/project/dir",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.txt",
    "content": "file content"
  }
}
```

**Exit codes**: `0` = success, `2` = block action (stderr fed to Claude), other = show error but continue.

For advanced control, output JSON to stdout:

```json
{
  "continue": true,
  "suppressOutput": true,
  "systemMessage": "Warning message for Claude",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": { "file_path": "/modified/path.txt" }
  }
}
```

## MCP Integration

The Model Context Protocol connects Claude Code to external tools. Three transport types:

```bash
# HTTP servers (recommended)
claude mcp add --transport http notion https://mcp.notion.com/mcp

# With authentication
claude mcp add --transport http api https://api.example.com/mcp \
  --header "Authorization: Bearer $TOKEN"

# Local stdio servers
claude mcp add --transport stdio github -- npx @modelcontextprotocol/server-github
```

Project-level config in `.mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "custom-api": {
      "type": "http",
      "url": "${API_BASE_URL:-https://api.example.com}/mcp",
      "headers": {
        "Authorization": "Bearer ${API_KEY}"
      }
    }
  }
}
```

Environment variable expansion supports `${VAR}` and `${VAR:-default}`. MCP tools appear as `mcp__<server>__<tool>`.

## Custom Slash Commands

Markdown files with optional YAML frontmatter in `.claude/commands/` (project) or `~/.claude/commands/` (user):

```markdown
---
description: Comprehensive security audit of codebase
allowed-tools: Bash(grep:*), Read, Glob
---

## Security Audit Context
- Current branch: !`git branch --show-current`
- Recent changes: !`git log --oneline -10`

Perform a comprehensive security audit:
1. Scan for hardcoded secrets
2. Check for SQL injection vulnerabilities
3. Review authentication logic

Target: $ARGUMENTS
```

Dynamic content with `!`backticks`` executes shell commands. Arguments via `$1`, `$2` (positional) or `$ARGUMENTS` (all). Subdirectories create namespaced commands.

## Skills: Auto-Invoked Context

Skills are model-invoked capabilities activated automatically based on context. Located in `skills/` with `SKILL.md` files:

```markdown
---
name: react-patterns
description: Best practices for React component development
allowed-tools:
  - Read
  - Grep
  - Glob
user-invocable: true
---

# React Development Patterns

When developing React components:
- Use functional components with hooks
- Implement proper error boundaries
- Follow container/presentational pattern
```

Unlike slash commands, **skills activate automatically** when Claude determines they're relevant.

## Plugin Caching and Shared File Resolution

When plugins are installed, Claude Code copies plugin files to a cache directory (`~/.claude/plugins/`). This has critical implications for file organization.

### How Caching Works

For marketplace plugins with relative paths, the path in `source` is copied recursively. If `"source": "./plugins/my-plugin"`, the entire `./plugins/my-plugin` directory is copied.

**Critical limitation**: Plugins cannot reference files outside their copied directory structure. Paths like `../shared-utils` won't work after installation because external files aren't copied.

### The pluginRoot Metadata Field

The `metadata.pluginRoot` field in marketplace.json sets a base path for all relative plugin sources:

```json
{
  "name": "company-marketplace",
  "owner": { "name": "DevOps Team" },
  "metadata": {
    "description": "Internal development tools",
    "version": "1.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "formatter",
      "source": "./formatter",
      "description": "Code formatting tools"
    },
    {
      "name": "linter", 
      "source": "./linter",
      "description": "Linting utilities"
    }
  ]
}
```

With `pluginRoot: "./plugins"`, source `"./formatter"` resolves to `./plugins/formatter`.

### Sharing Files Across Plugins

**Option 1: Symlinks** — Symlinks pointing outside the plugin root are followed during copying. Git preserves symlinks on macOS/Linux, but Windows compatibility is unreliable.

```
marketplace/
├── shared/
│   └── utils.sh              # Actual file
└── plugins/
    └── my-plugin/
        └── shared -> ../../shared   # Symlink followed during copy
```

**Option 2: Restructure layout** — Place shared directory inside each plugin source (causes duplication in source).

**Option 3: Marketplace-wide source with explicit component paths (recommended for shared resources)**

Set `"source": "./"` to copy the entire marketplace, then use explicit component paths so multiple plugins can reference a common `shared/` folder:

```
marketplace/
├── .claude-plugin/
│   └── marketplace.json
├── shared/
│   ├── commands/
│   │   └── common-review.md
│   ├── agents/
│   │   └── security-reviewer.md
│   └── scripts/
│       └── utils.sh
└── plugins/
    ├── plugin-a/
    │   └── commands/
    │       └── deploy.md
    └── plugin-b/
        └── commands/
            └── test.md
```

**marketplace.json:**
```json
{
  "name": "my-marketplace",
  "owner": { "name": "Team" },
  "plugins": [
    {
      "name": "plugin-a",
      "source": "./",
      "commands": [
        "./plugins/plugin-a/commands",
        "./shared/commands"
      ],
      "agents": "./shared/agents"
    },
    {
      "name": "plugin-b",
      "source": "./",
      "commands": [
        "./plugins/plugin-b/commands",
        "./shared/commands"
      ],
      "agents": "./shared/agents"
    }
  ]
}
```

Both plugins receive:
- Their own unique commands
- The shared `common-review.md` command
- The shared `security-reviewer.md` agent
- Access to `${CLAUDE_PLUGIN_ROOT}/shared/scripts/utils.sh` in hooks

**Trade-off**: Each installed plugin duplicates the entire marketplace in cache, increasing storage. For large marketplaces with many plugins, this can cause significant bloat.

### The ${CLAUDE_PLUGIN_ROOT} Variable

After installation, `${CLAUDE_PLUGIN_ROOT}` resolves to the plugin's absolute cache path. Use in hooks, MCP servers, and scripts:

```json
{
  "hooks": {
    "PostToolUse": [{
      "hooks": [{
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/scripts/process.sh"
      }]
    }]
  }
}
```

## Plugin Marketplace and Distribution

Plugins distribute through Git-based marketplaces. Each contains `.claude-plugin/marketplace.json`:

```json
{
  "name": "company-plugins",
  "owner": {
    "name": "Engineering Team",
    "email": "team@example.com"
  },
  "metadata": {
    "description": "Internal development tools",
    "version": "1.0.0",
    "pluginRoot": "./plugins"
  },
  "plugins": [
    {
      "name": "security-scanner",
      "source": "./security-scanner",
      "description": "Automated security scanning",
      "version": "1.0.0",
      "category": "security"
    }
  ]
}
```

### Marketplace Schema

**Required fields:**
| Field | Type | Description |
|-------|------|-------------|
| `name` | string | Marketplace identifier (kebab-case) |
| `owner` | object | Maintainer info (`name`, `email`) |
| `plugins` | array | List of available plugins |

**Optional metadata:**
| Field | Type | Description |
|-------|------|-------------|
| `metadata.description` | string | Marketplace description |
| `metadata.version` | string | Marketplace version |
| `metadata.pluginRoot` | string | Base path for relative plugin sources |

### Plugin Entry Fields

**Required:**
- `name`: Plugin identifier
- `source`: Where to fetch (path, GitHub, or Git URL)

**Optional:**
- `description`, `version`, `author`, `homepage`, `repository`, `license`, `keywords`
- `category`, `tags`: For organization/search
- `strict`: Require plugin.json (default: true). When false, marketplace entry serves as manifest
- `commands`, `agents`, `hooks`, `mcpServers`: Override component paths

### Plugin Sources

```json
// Relative path
{ "name": "my-plugin", "source": "./plugins/my-plugin" }

// GitHub
{ "name": "github-plugin", "source": { "source": "github", "repo": "owner/repo" }}

// Git URL
{ "name": "git-plugin", "source": { "source": "url", "url": "https://gitlab.com/team/plugin.git" }}
```

### Plugin Management Commands

```bash
# Add marketplace
/plugin marketplace add company/claude-plugins

# Install plugin
/plugin install security-scanner@company-plugins --scope project

# Enable/disable
/plugin enable formatter@company-plugins
/plugin disable formatter@company-tools

# Local development testing
claude --plugin-dir ./my-plugin

# Validate
claude plugin validate .
```

## Hierarchical Configuration

Configuration precedence (highest to lowest):

1. **Enterprise managed** (`/Library/Application Support/ClaudeCode/managed-settings.json`)
2. **Command line arguments**
3. **Local project** (`.claude/settings.local.json`)—gitignored
4. **Shared project** (`.claude/settings.json`)—team-shared
5. **User** (`~/.claude/settings.json`)—personal global

Example `.claude/settings.json`:

```json
{
  "model": "claude-sonnet-4-20250514",
  "permissions": {
    "allow": ["Bash(npm run lint)", "Read(~/.zshrc)"],
    "deny": ["Read(./.env)", "Bash(sudo:*)"]
  },
  "hooks": {},
  "enabledPlugins": {
    "formatter@company-tools": true,
    "security@anthropics": true
  },
  "extraKnownMarketplaces": {
    "company-tools": {
      "source": { "source": "github", "repo": "company/claude-plugins" }
    }
  }
}
```

## Key Environment Variables

| Variable | Purpose |
|----------|---------|
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory (use in scripts) |
| `CLAUDE_PROJECT_DIR` | Project root directory |
| `ANTHROPIC_API_KEY` | API authentication |
| `MAX_THINKING_TOKENS` | Extended thinking budget |
| `MCP_TIMEOUT` | MCP server startup timeout |

## Official and Community Plugins

**Anthropic official** (`anthropics/claude-code/plugins`):
- `pr-review-toolkit`: Multi-agent PR review
- `plugin-dev`: Guided plugin development
- `hookify`: Create hooks from conversation patterns
- `frontend-design`: High-quality frontend interfaces

**Community marketplaces**:
- CCPlugins (`ccplugins/awesome-claude-code-plugins`): 100+ plugins
- Jeremy Longshore's marketplace: DevOps, AI/ML, creator tools
- Official submission directory: `claudecodecommands.directory`

**Popular npm MCP servers**:
- `@modelcontextprotocol/server-github`
- `@steipete/claude-code-mcp`
- `@zilliz/claude-context-mcp`

## Best Practices

**Plugin development:**
- Create skills early for consistent code patterns
- Use namespaced commands (`/plugin:command`)
- Test locally with `--plugin-dir` before publishing
- Use symlinks for shared files across plugins

**Hook security:**
- Hooks execute with user credentials—review before registration
- Use `chmod +x` on scripts
- Quote shell variables (`"$VAR"`)
- Block path traversal by checking for `..`

**MCP optimization:**
- Each MCP server adds tool definitions to system prompt
- Disable unused servers
- Use `@mentions` to toggle servers during sessions

**Configuration:**
- Edit `~/.claude.json` directly for complex MCP setups
- Use `.claude/settings.local.json` for personal settings
- Enterprise `managed-settings.json` cannot be overridden

## References

- Official docs: https://code.claude.com/docs/en/plugins
- Plugin reference: https://code.claude.com/docs/en/plugins-reference
- Marketplace docs: https://code.claude.com/docs/en/plugin-marketplaces
- Hooks guide: https://code.claude.com/docs/en/hooks-guide
- MCP docs: https://code.claude.com/docs/en/mcp
- Official plugins: https://github.com/anthropics/claude-code/tree/main/plugins