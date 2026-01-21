workflows
small sized quick easy work - low detail planning
- in built planning or byo plan - doesnt have to be fleshed out just needs to be an outline of whats wanted
- implementation planner outputs a single job with a task list
- the job is handed off to an implementation agent

small sized complex work - high detail planning phase included, single agent workflow
- in built planning or byo plan - doesnt have to be fleshed out just needs to be an outline of whats wanted
- planning loop
    - wf-gap-filler: auto-fills gaps
    - wf-gap-reviewer: clarifies with user
    - wf-fact-fixer: fixes factual errors
    - wf-fact-checker: verifies claims against codebase
    - wf-phase-structurer: structure the spec into jobs that are vertical slices
- implementation planner outputs a single job with a task list
- the job is handed off to an implementation agent

medium sized easy work - low detail planning used, agent driven implementation execution
- in built planning or byo plan - doesnt have to be fleshed out just needs to be an outline of whats wanted
- implementation planner outputs multiple jobs - each has a task list
- each job is handed off to an implementation agent sequentially

medium sized complex work - high detail planning phase included, agent driven implementation execution
- in built planning or byo plan - doesnt have to be fleshed out just needs to be an outline of whats wanted
- planning loop
    - wf-gap-filler: auto-fills gaps
    - wf-gap-reviewer: clarifies with user
    - wf-fact-fixer: fixes factual errors
    - wf-fact-checker: verifies claims against codebase
    - wf-phase-structurer: structure the spec into jobs that are vertical slices
- implementation planner outputs multiple jobs - each has a task list
- phase implementation orchestrator executes each job sequentially

large workflow - high detail planning phase included, phases with jobs, agent driven implementation execution for jobs in phases
- in built planning or byo plan - doesnt have to be fleshed out just needs to be an outline of whats wanted
- planning loop
    - wf-gap-filler: auto-fills gaps
    - wf-gap-reviewer: clarifies with user
    - wf-fact-fixer: fixes factual errors
    - wf-fact-checker: verifies claims against codebase
    - new agent: maps the spec into phases that are vertical slices
    - wf-phase-structurer: structure the phases into jobs
- for each phase - implementation planner outputs multiple jobs - each has a task list
- for each phase - phase implementation orchestrator executes each job sequentially






