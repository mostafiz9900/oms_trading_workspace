# Task: Work on setup-claude.sh
**Added By**: mostafiz9900
**Date Added**: 2026-10-31
**Priority**: 🟢 Low
**Module**: tooling (.claude setup)
**Estimated Effort**: Small
**Assigned To**: mostafiz9900

## Description
The user asked to keep `setup-claude.sh` in mind for later work (no change asked yet).
The script (1246 lines, committed in `9d4fd10`) bootstraps the Claude memory system in a project:
creates `.claude/{memory,modules,tasks/*,commands}`, `settings.json`, `CLAUDE.md` and memory templates.
It runs in SAFE MODE when `CLAUDE.md` or `.claude/` exists (only creates missing files).

## Acceptance Criteria
- [ ] Ask the user what to change in the script before editing

## Notes
- Do not run it in this repo without the user: CLAUDE.md and .claude/ already exist (safe mode would only add missing files, e.g. `.claude/modules/`)
- The project has no `.claude/modules/` yet; the script creates that folder

## Related Files
- `setup-claude.sh`
