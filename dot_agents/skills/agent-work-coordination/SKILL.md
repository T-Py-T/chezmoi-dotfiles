---
name: agent-work-coordination
description: Coordinate multiple coding agents with Beads using unique worker identities, atomic task claims, dependency-aware handoffs, and isolated workspaces. Use when a repository contains .beads, when several agents need to divide work, or when work must survive context compaction and resume safely.
---

# Agent Work Coordination

Use Beads as the durable task and dependency ledger. It does not isolate source
files and does not schedule agents. Every worker still needs a separate COW
workspace, worktree, clone, or container.

## Start safely

1. Confirm `bd` is available and the repository already contains `.beads/`.
2. Never initialize Beads automatically. Initialization changes repository or
   local Git state and requires explicit human approval.
3. Give every concurrent worker a unique stable ID. Never reuse one ID for two
   live workers.
4. Claim work through the wrapper:

   ```sh
   agent-bd <harness> <worker-id> -- ready --claim --json
   ```

5. Read the claimed issue, its dependencies, acceptance criteria, and notes
   before changing code.

## Work and hand off

- Keep code isolation and task ownership separate: an atomic Beads claim does
  not prevent two workers from editing the same checkout.
- Record useful progress and reproducible evidence on the issue:

  ```sh
  agent-bd <harness> <worker-id> -- update <id> \
    --append-notes "Tests: <command and result>; change: <commit or patch>"
  ```

- Add dependency edges for discovered blockers instead of relying on chat
  memory. Do not close a blocked issue.
- Close only after acceptance checks pass:

  ```sh
  agent-bd <harness> <worker-id> -- close <id> --reason "<verified outcome>"
  ```

- If stopping early, leave current state, next action, relevant paths, and test
  output in notes, then deliberately block, release, or reassign the issue.

## Concurrency boundaries

- Atomic claiming is global only for workers using the same Beads database or
  the same shared Dolt server. Independently replicated hosts can be stale.
- Embedded mode is single-writer. Use Beads server mode for concurrent writers
  on one trusted host. A set of separate cross-host servers is not one atomic
  claim domain.
- Do not depend on unreleased leases, heartbeats, or crash recovery. Treat a
  stale claim as a human-reviewed recovery decision.
- Use `bd dolt push` and `bd dolt pull` for versioned synchronization. Do not
  treat exported JSONL as the canonical distributed merge mechanism.

## Initialization, only when explicitly authorized

For a local pilot that must not add tracked files or hooks:

```sh
BD_DISABLE_METRICS=1 bd init --stealth --skip-hooks --skip-agents --non-interactive
```

Warn that stealth mode writes `.git/info/exclude`. Use an external `BEADS_DIR`
when even that local Git mutation is unwanted. Never let Beads automatically
commit project files, and keep `BD_DISABLE_METRICS=1` enabled.
