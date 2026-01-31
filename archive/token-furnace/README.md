# Token Furnace

## Motivation

I wanted to build something that creates specs and implementation plans with no gaps and no room for interpretation.

The problem with typical AI-assisted development is ambiguity. You describe what you want, the AI interprets it, and somewhere in between your intent and its output, details get lost or assumptions creep in. When you finally execute, you discover the gaps—missing edge cases, unclear requirements, decisions that were never made.

Token Furnace takes a different approach: systematic refinement before execution. Instead of jumping from idea to code, it forces a rigorous process:

The goal is zero ambiguity. Every decision made explicitly. Every requirement traced to implementation. Every plan audited before execution.

---

## Quick Start

Token Furnace is a 4-stage pipeline that turns ideas into verified implementation through systematic research and planning. Run these commands in sequence:

```
/intake    → Turn your idea into a verified spec with phases
/smelter   → Convert each phase into a detailed implementation plan
/foundry   → Transform plans into executable build plans
/forge     → Execute build plans and verify results
```

### Prerequisites

Token Furnace works best with **topical skills**—codebase-specific knowledge files. Generate them first:

```
/scan-architecture    # Scan your codebase and create skills
```

### Minimal Example

```bash
# 1. Start with your messy idea
/intake
> "I want to add user authentication with JWT tokens, logout, and session management"
# Intake organizes, researches gaps, clarifies, verifies, and outputs:
# plans/auth/auth-spec.md
# plans/auth/auth-spec-phases.md

# 2. Create implementation plans for each phase
/smelter
> Spec path: plans/auth/auth-spec.md
# Creates: plans/auth/phase-1-plan.md, phase-2-plan.md, etc.

# 3. Convert to executable build plans
/foundry
> Spec path: plans/auth/auth-spec.md
# Creates: plans/auth/phase-1-build.md, phase-2-build.md, etc.

# 4. Execute and verify
/forge
> Spec path: plans/auth/auth-spec.md
> Provider: claude
# Executes each build plan, verifies success criteria, produces working code
```

---

## Detailed Usage

### Stage 1: Intake (`/intake`)

**Purpose:** Transform unstructured ideas into a verified spec organized into implementation phases.

**Workflow:**

1. **Organize** — Describe your idea in any form. Intake structures it and identifies gaps. For each gap, `ore-scout` researches your codebase instead of asking you. Loop continues until you say "ready to write."

2. **Prospector (Autonomous)** — `prospector` autonomously fills gaps with high-confidence solutions found in your codebase. Iterates up to 4 times until COMPLETE.

3. **Clarify** — `assayer` reads your spec as an implementer would, finding gaps that would block development. It uses a **WHAT vs HOW filter**: WHAT questions (requirements, outcomes) are flagged; HOW questions (implementation details) are deferred. It attempts to fill WHAT gaps from skills/codebase, then presents:
   - **Suggestions** — Gaps it found answers for (confirm/reject/modify)
   - **Questions** — Gaps needing your input
   - **Unanswered** — Existing open questions

   Loop continues until assayer returns `IMPLEMENTATION_READY`.

4. **Refiner (Autonomous)** — `refiner` autonomously fixes obvious factual errors (wrong file paths, method names, return types). Iterates up to 4 times until COMPLETE.

5. **Verify** — `touchstone` fact-checks claims against your codebase, returning:
   - **Corrections** — Claims contradicting evidence (confirm/reject/modify)
   - **Questions** — Claims needing clarification

   Loop continues until touchstone returns `VERIFIED`.

6. **Structure** — `mold` reorganizes the spec into **vertical slices** (end-to-end features) instead of horizontal layers, ensuring no content is lost.

**Outputs:**
- `plans/[slug]/[slug]-spec.md` — Verified spec
- `plans/[slug]/[slug]-spec-phases.md` — Spec organized into phases

---

### Stage 2: Smelter (`/smelter`)

**Purpose:** Convert each spec phase into a detailed implementation plan with verifiable success criteria.

**Per-Phase Workflow:**

1. **deep-drill** — Researches your codebase deeply for this phase. Finds analogous implementations to use as templates. Produces a plan with:
   - Pattern references (which files to follow)
   - Architectural impact
   - Step-by-step implementation guide

2. **slag-check** — Audits the plan against the spec:
   - Every spec requirement has a plan step
   - Pattern files exist and are appropriate
   - Steps are ordered correctly
   - No gaps, vagueness, or scope creep

   Returns `PASS` or `ISSUES`.

3. **Automatic retry** — If issues found, automatically feeds issues back to deep-drill for up to 3 attempts without user intervention.

4. **Human checkpoint** — After retries exhausted (if ISSUES) or on first PASS, user reviews and chooses: retry with guidance, accept anyway, or provide guidance.

5. **proof** — Once approved, derives exhaustive success criteria from both spec and plan. Each criterion specifies exactly what to verify and how—checkable by reading code, not running it.

**Output:** `plans/[slug]/phase-N-plan.md` for each phase

---

### Stage 3: Foundry (`/foundry`)

**Purpose:** Transform implementation plans into executable build plans with skill assignments.

**Per-Phase Workflow:**

1. **Skill discovery** — Lists available skills in your environment
2. **Skill matching** — Determines which skills apply based on technologies and implementation steps
3. **cast** — Converts the plan into a self-contained build plan with:
   - Tasks broken into specific jobs
   - Skills assigned to relevant tasks
   - Instructions for loading skills
   - Audit jobs to verify completion

**Output:** `plans/[slug]/phase-N-build.md` for each phase

---

### Stage 4: Forge (`/forge`)

**Purpose:** Execute build plans and verify success criteria.

**Setup:** Select AI provider (claude, glm, or minimax)

**Per-Phase Workflow:**

1. **Execute** — Spawns an agent with the build plan. The plan is self-contained—it tells the agent which skills to load and what to do.

2. **temper** — Verifies success criteria against actual code:
   - Checks each criterion
   - Reports `PASS` or `FAIL` with evidence

3. **Retry loop** — If temper fails, passes failed criteria back to the executing agent (up to 3 attempts)

**Output:** Implemented code verified against all success criteria

---

### Skill-Driven Development

Token Furnace integrates with **topical skills** at every major intersection:

| Stage | Skill/Agent Consulted | Purpose |
|-------|----------------|---------|
| Intake | ore-scout | Research patterns instead of asking user |
| Intake | prospector | Autonomously fill gaps with high-confidence solutions |
| Intake | assayer | Find implementation-blocking gaps (WHAT, not HOW) |
| Intake | refiner | Autonomously fix factual errors |
| Intake | touchstone | Verify spec claims against codebase |
| Smelter | deep-drill | Reference skills for pattern guidance |
| Smelter | slag-check | Verify pattern files exist |
| Foundry | cast | Assign skills to implementation tasks |
| Forge | executor | Load skills before implementing |

Generate topical skills from your codebase using the `creating-topical-skills` plugin:

```
/scan-architecture
```

This creates a feedback loop: better skills → better plans → better implementations.

---

### File Structure

```
plans/[slug]/
├── [slug]-spec.md              # Verified spec (from intake)
├── [slug]-spec-phases.md       # Spec organized into phases (from mold)
├── phase-1-plan.md             # Implementation plan (from deep-drill + proof)
├── phase-2-plan.md
├── phase-3-plan.md
├── phase-1-build.md            # Executable build plan (from cast)
├── phase-2-build.md
└── phase-3-build.md
```

---

### Human Checkpoints

Token Furnace includes strategic human-in-the-loop points:

- **After organize** — You approve the structured spec before autonomous loops run
- **After prospector loop** — You see what was autonomously filled (output verbatim)
- **During clarification** — You respond to assayer questions (loop until IMPLEMENTATION_READY)
- **After refiner loop** — You see summary of autonomous corrections
- **During verification** — You respond to touchstone corrections (loop until VERIFIED)
- **After automatic retry exhausted** — You review audit results and choose retry/accept/guidance
- **On PASS checkpoint** — You review and approve the plan before proof adds success criteria
- **After temper failure** — You can intervene after 3 retry attempts

---

## Skill-Driven Development

Token Furnace works in conjunction with **topical skills**—codebase-specific knowledge files that capture patterns, conventions, and domain rules.

At every major intersection in the workflow, agents are pushed to consult skills:
- **ore-scout** checks skills when researching patterns
- **prospector** checks skills when autonomously filling gaps
- **assayer** and **touchstone** verify against skills when auditing specs
- **refiner** checks skills when fixing factual errors
- **deep-drill** references skills when finding analogous implementations
- **slag-check** verifies pattern files referenced in plans
- **cast** assigns skills to tasks so executing agents follow the right patterns
- **forge** loads skills before execution so the implementing agent knows the conventions

This creates a feedback loop: the more your codebase is captured in skills, the better Token Furnace works. Skills prevent agents from inventing patterns that don't match your codebase, and ensure implementations follow established conventions.

The sister plugin **creating-topical-skills** generates these skills from your codebase. Run its architecture scanner to analyze your code and produce skills that Token Furnace agents can reference throughout the workflow.

---

## Workflows

Token Furnace has four workflows that run in sequence: **Intake → Smelter → Foundry → Forge**.

---

### 1. Intake

Turns messy thoughts into a verified, structured spec ready for implementation planning.

**Phases:**

**A. Organize** — The user dumps their thoughts. Intake organizes them into structure, identifies gaps, and for each gap invokes **ore-scout** to research the codebase rather than asking the user. Presents findings and options. Loops until the user says "ready to write", then writes the spec.

**A2. Prospector Loop (Autonomous)** — Intake invokes **prospector** to autonomously fill gaps with high-confidence solutions. Prospector iterates up to 4 times until COMPLETE (no gaps left) or max iterations reached. Output is presented verbatim to the user.

**B. Clarify** — Invokes **assayer** to read the spec as an implementer would. Assayer identifies blocking gaps (things that would prevent implementation), attempts to fill them from codebase/skills, and returns:
- **Suggestions** — Gaps it found answers for (user confirms/rejects/modifies)
- **Questions** — Gaps needing user input
- **Unanswered** — Existing open questions from the spec

Assayer uses a **WHAT vs HOW filter**: WHAT questions (requirements, outcomes) are treated as gaps; HOW questions (implementation details, patterns) are deferred to implementation.

User responds, assayer applies changes to spec. Loop repeats with a fresh assayer until it returns IMPLEMENTATION_READY or COMPLETE.

**B2. Refiner Loop (Autonomous)** — Intake invokes **refiner** to autonomously fix obvious factual errors in the spec. Refiner iterates up to 4 times until COMPLETE (nothing left to fix), then summarizes corrections made.

**C. Verify** — Invokes **touchstone** to fact-check the spec. Touchstone verifies claims against the codebase and returns:
- **Corrections** — Claims that contradict evidence (user confirms/rejects/modifies)
- **Questions** — Claims needing clarification

User responds, touchstone applies changes. Loop repeats until it returns VERIFIED.

**D. Structure** — Invokes **mold** to restructure the verified spec into implementation phases. Mold organizes content into vertical slices (complete features end-to-end) rather than horizontal layers, performs a comparative audit to ensure no content was lost, and outputs the phases file.

**Output:** `plans/[slug]/[slug]-spec.md` and `plans/[slug]/[slug]-spec-phases.md`

---

### 2. Smelter

Processes each phase through deep research and auditing to produce implementation plans with success criteria.

**Per-Phase Loop:**

For each phase in the phases file:

1. **deep-drill** — Researches the codebase deeply for this phase. Follows abstractions to concrete code, finds analogous implementations to use as templates, produces a detailed plan with pattern references and file paths.

2. **slag-check** — Audits the plan against the spec. Checks:
   - Does every spec requirement have a corresponding plan step?
   - Are pattern files real and appropriate?
   - Are steps in logical order with dependencies respected?
   - Are there gaps, vague steps, or scope creep?

   Returns PASS or ISSUES.

3. **Automatic retry** — If ISSUES, automatically feeds issues back to deep-drill for up to 3 attempts without user intervention.

4. **Human checkpoint** —
   - If retries exhausted (still ISSUES): User chooses to retry with guidance, accept anyway, or provide guidance.
   - If PASS: User reviews the plan and confirms or requests changes.

5. **proof** — Once approved, derives exhaustive success criteria from both spec and plan. Each criterion specifies exactly what to verify and how—checkable by reading code, not running it.

**Output:** `plans/[slug]/phase-N-plan.md` for each phase, each with a Success Criteria section.

---

### 3. Foundry

Transforms implementation plans into executable build plans with skill assignments.

**Per-Phase Process:**

For each phase plan:

1. **Skill discovery** — Lists available skills in the environment (fresh each phase).

2. **Skill matching** — Reads the phase plan and determines which skills apply based on technologies, domains, and implementation steps mentioned.

3. **cast** — Transforms the plan into an executable build plan:
   - Breaks implementation steps into specific, actionable jobs
   - Assigns matched skills to relevant tasks
   - Includes instructions for how to load and use skills
   - Adds audit jobs to verify completion
   - Creates a self-contained document an agent can execute in isolation

**Output:** `plans/[slug]/phase-N-build.md` for each phase, containing tasks with jobs and skill assignments.

---

### 4. Forge

Executes build plans and verifies success criteria are met.

**Setup:** User selects AI provider (Claude, GLM, or MiniMax) for execution.

**Per-Phase Loop:**

For each build plan:

1. **Execute** — Spawns an agent with the build plan. The build plan is self-contained—it tells the agent which skills to load, what tasks to complete, and how to verify its work.

2. **temper** — After execution reports complete, temper verifies success criteria from the phase plan:
   - Checks each criterion against the actual codebase
   - Reports PASS or FAIL with evidence for each
   - If any criterion fails, returns the failed criteria list

3. **Retry loop** — If temper fails:
   - Failed criteria are passed back to the executing agent as context
   - Agent fixes the issues and re-executes
   - Temper verifies again
   - Up to 3 total attempts before escalating to user

**Output:** Implemented code, verified against all success criteria derived from spec and plan.

---

## Recent Changes

### January 2026

- **WHAT vs HOW Filter** — Added to `assayer` and `prospector` skills to prevent treating implementation details (HOW) as gaps. Only requirements and outcomes (WHAT) are flagged as needing clarification.

- **Prospector/Refiner Autonomous Loops** — Added autonomous gap-filling (`prospector`) and error-fixing (`refiner`) loops to intake workflow. Each iterates up to 4 times until COMPLETE, reducing user friction for obvious fixes.

- **Automatic Retry in Smelter** — `deep-drill` now automatically retries up to 3 times when `slag-check` finds issues, without user intervention. Human checkpoint only occurs after retries are exhausted or on first PASS.

- **Cast Agent Rewrite** — `cast` agent now preserves all phase plan data (Pattern Reference, Architectural Impact, Dependencies, Open Questions) in build plans, making them fully self-contained for execution.

- **Prospector Verbatim Output** — Intake now outputs prospector response verbatim to chat, showing exactly what was autonomously filled.

