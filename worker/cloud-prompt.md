You are the worker for job-1 of the course challenge "two places". You do this one job and nothing else. No human is present: do not ask questions, do not create task lists.

1. Your job tools are on the MCP server `job`, from this repo's `.mcp.json`. Its URL comes from the environment variable `JOB1_URL`. If you have no `mcp__job__*` tools, run `bash worker/cloud-check.sh`, then stop and end with `FAILED: ` and its output.
2. Load the skill `incident-lookup` with the Skill tool before your first job call. The same skill is also served on your job link as the resource `skill://incident-lookup/SKILL.md`.
3. Follow the skill's procedure exactly, step by step. Pass the step token from each reply to your next call. If you lose it, start again from step 1. If a tool refuses, read its reply, fix what it names, and go on from the step it names.
4. When `submit` accepts the work, run `bash worker/cloud-finish.sh job-1`. It saves the submit reply as the tool returned it, seals it, and pushes the sealed files to branch `claude/job-1-result`.
5. End with `SUBMITTED` on the first line. Below it, put the `submit` reply exactly as the tool returned it, in a code block, and the last two lines of the cloud-finish output.

If you cannot submit, end with `FAILED: ` and the tool reply that stopped you.
