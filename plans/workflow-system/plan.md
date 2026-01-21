large -
user uses claude plan mode to create a plan

this is an orchestrator - spec-planner
---
This isn't exactly what we need but it is a good example of how the loop works.
- Prospector Loop
- Assayer Loop
- Refiner Loop
- Touchstone Loop
---

this is an orchestrator - implementation-planner
---
- at this point we have a highly detailed spec document detailing how everything should be done down to the smallest detail
This is where our new functionality comes in. At this point we need to map the spec into phase-spec documents. First the agent makes a judgment: is this trivial enough for one agent to handle in one go? Use criteria/validation rules/guidelines for this decision. If yes → create one phase-spec. If no → split into multiple. We need an agent that will do this, each phase-spec needs to be a vertical slice of the spec, a self contained unit of work with as little dependency on other phases as possible. e.g. if there are data models to make they can be made first, if there is a new service to be made that can be made in isolation without affecting anything else, make that first etc. Everything needs to be checked for its dependencies in implementation and those dependencies will dictate what goes in what phase.
Then these phase-spec documents need to be output into a folder in `plans/[feature-slug]/phase-specs/[feature-slug]-[phase-slug]-spec.md` so if there were 9 phases then the folder will have 9 documents. No data should be lost in this process and no ideas should be added in this process. We strictly want a reorganisation of the spec into workable phases.
- now we need another agent that organises the phases into jobs, jobs are a logical group of tasks that need to be completed for a smaller goal. This is just organising work, first we broke it down into phases and now each phase needs to be broken down into jobs. Jobs should be sized by rules and criteria - can have as many jobs as needed in a phase but bias against many small jobs. For small work this naturally results in 1 phase with 1-2 jobs. No data should be lost in this process and no ideas should be added in this process. We strictly want a reorganisation of the spec into workable jobs. These should be in `plans/[feature-slug]/phase-job-specs/[feature-slug]-[phase-slug]-job-spec.md`
- now each phase-job-spec needs to be processed into a detailed implementation plan that has its own document
this is the example loop from smelter:
This isn't exactly what we need but it is a good example of how the loop works, we have different input and output situations.
Deep-drill - the output needs to be changed to job with tasks and match the output of wf-job.md
Slag-check
- show user issues
- user input on issues - fix issues with user guidance
The deliverable here is going to be a folder with folders in it, each folder will have a file for each job of the phase
`plans/[feature-slug]/phase-implementation/[phase-slug]/[job-slug].md`
- at this point we now have a folder with a folder for each phase, in each folder is files, each file contains an implementation plan for a job.
---

this is an orchestrator - implementation-execution
---
- now we need to do implementation for each phase which is an orchestrator - it should launch an agent to do a job file.
After the implementation is done we need another agent that audits the work and puts a section at the bottom of the plan called amendments or audit report.
new agent - the implementation agent should read the amendments section if there is anything in it, then go through each task in the job and do it again with the knowledge that another dev has already attempted the job and they are going to finish the work with the amendments to go by. If there are no amendments they will be doing the work from scratch.
new agent - the audit agent does the audit, fills out the amendments section and returns a pass or fail signal to the orchestrator.
- and that's it.
---
