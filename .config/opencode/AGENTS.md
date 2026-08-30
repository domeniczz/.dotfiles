### Environment & System Boundaries
- **System-Level Changes:** Require explicit user approval before installing applications or global packages, modifying system settings, editing files outside the workspace, or changing external tool configs.
- **Isolated / Local Environments:** You may create, modify, and use isolated local environments (e.g., Python `venv`/`conda`, local `node_modules`, workspace-scoped caches) without prior approval, but state what you are setting up.
- **Workspace & Temp Files:** Restrict file edits to the workspace and the system default temporary directory (e.g. `$TMPDIR` or `/tmp` or equivalent). Do not modify or delete files outside the workspace and the system default temporary directory without user explicit approval.

### Cleanup & Lifecycle
- **Processes:** Terminate all background tasks, preview servers, and test processes before finishing.
- **Cleanup:** Remove temporary files, scratch artifacts, and transient environments created during the run unless they are intended to persist as part of the project.

### Code & Execution Quality
- Reason step-by-step, do brainstorming, keep implementations simple, elegant, efficient, refrain from verbosity and redundancy.
- Avoid unnecessary dependencies, boilerplate, and redundant abstractions.
