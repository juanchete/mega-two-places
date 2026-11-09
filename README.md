# mega-two-places

Workers for MEGA S02E04 "two places". Each job runs in its own headless Claude Code process, with only that job's MCP link.

- Skills live in one folder: `.agents/skills`. `.claude/skills` is a link to it, not a copy.
- `worker/run.sh <job-id> <skill>` runs one worker. `JOB_URL` holds the job link. Never commit it.
- Output goes to `out/` (git-ignored): the transcript and the `submit` reply as the tool returned it. On Actions, `worker/seal.sh` encrypts `out/` before upload (the repo is public); `worker/open.sh` opens it with the private key, which stays on the local machine.

| Job | Skill | Where |
|---|---|---|
| job-1 | incident-lookup | GitHub Actions (`worker.yml`, secrets `JOB1_URL`, `CLAUDE_CODE_OAUTH_TOKEN`) |
| job-2 | voice-to-memo | Local machine |
