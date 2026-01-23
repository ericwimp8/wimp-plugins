#!/usr/bin/env bash
# Hook that fires after compaction to remind orchestrator to check TaskList

set -euo pipefail

# Output context injection as JSON
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "COMPACTION RESUME - MANDATORY ACTION REQUIRED\n\nYou have resumed after context compaction. Before responding to the user, you MUST:\n\n1. Call TaskList immediately to see your current tasks\n2. Report to the user what tasks exist and their status\n3. Then continue from where you left off\n\nDo NOT skip this. Do NOT just answer questions first. Call TaskList NOW."
  }
}
EOF

exit 0
