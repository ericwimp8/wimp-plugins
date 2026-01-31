# Agent Progress Logging

## Problem

When token-furnace agents run, there's no visibility into what they're doing. Users can't see progress, and debugging failures is difficult because there's no record of what happened.

## Desired Behavior

The system should log agent activity so users can:
- See which agent is currently running
- Track progress through phases
- Review what happened after completion
- Debug failures by seeing the sequence of events

Logs should include:
- Agent name and start/end times
- Input received (summarized, not full content)
- Output returned
- Any errors encountered

## Scope

### In Scope
- Logging agent invocations from orchestrators (intake, smelter)
- Storing logs in a predictable location
- Human-readable format

### Out of Scope
- Log rotation or cleanup
- Structured query interface
- Real-time streaming to UI

## Constraints

- Logs must not contain sensitive data
- Must work with existing agent invocation patterns
- Should not require changes to agent definitions

## Open Questions

None - requirements are clear.

## Codebase Context

- Orchestrators are in `skills/` directory (intake, smelter)
- Agents are invoked via Task tool with specific prompt templates
- Output files go in `plans/[slug]/` directories
