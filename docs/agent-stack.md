# Portable agent coordination stack

Verified on 2026-08-07 for macOS, Linux, and WSL2. This is the operational
layer shared by OMP, Pi, Hermes, Codex, and other shell-capable coding agents.

## The architecture

Large agent jobs need three separate concerns. No one tool safely replaces the
others:

| Concern | Selected mechanism | What it does not do |
|---|---|---|
| Source and history | Git; Jujutsu remains an opt-in Git-compatible experiment | Does not assign work or prevent checkout collisions |
| Code isolation | Harness COW workspace, worktree, clone, or container | Does not preserve task ownership or dependency state |
| Work coordination | Beads task/dependency graph with atomic claims in one database | Does not schedule agents or isolate code |
| Procedural memory | `~/.agents/skills/agent-work-coordination` | Is not a replicated event store or semantic memory database |

The rule is therefore **isolated workspace + unique worker identity + atomic
claim + evidence-backed handoff**. Vector memory can later improve recall, but
it must not become the authority for task ownership.

## Installed and pinned

| Tool | Version | Ownership | Reason |
|---|---:|---|---|
| [Beads](https://github.com/gastownhall/beads/releases/tag/v1.1.2) | 1.1.2 | checksum-pinned release | Durable dependency graph and atomic same-database claims |
| [OMP](https://github.com/can1357/oh-my-pi/releases/tag/v17.2.10) | 17.2.10 | checksum-pinned release | Multi-agent harness with COW/worktree isolation options |
| [Pi](https://github.com/earendil-works/pi/releases/tag/v0.84.1) | 0.84.1 | checksum-pinned release | Current release is newer than the checked Homebrew formula |
| [Hermes](https://github.com/NousResearch/hermes-agent/releases/tag/v2026.8.3) | 0.20.0 / 2026.8.3 | commit-pinned official installer | Upstream does not support Homebrew or pip installation |
| Dolt | Homebrew current | Homebrew | Enables one authoritative Beads server for concurrent agent claims; no service is auto-started |

`scripts/run_after_20_agent_tools.tmpl` maps each supported OS/architecture to
an upstream asset and SHA-256 digest. It installs versioned files beneath
`~/.local/share/agent-tools` and manages only symlinks in `~/.local/bin`. It
refuses to overwrite regular files. The Hermes checkout is updated only when it
is clean; a dirty checkout stops the apply rather than being reset.

The shared skill location follows the native user skill convention used by
[Codex](https://learn.chatgpt.com/docs/build-skills) and
[Pi](https://github.com/earendil-works/pi/blob/main/packages/coding-agent/docs/skills.md).
OMP discovers `.agent`/`.agents` skills through its agents provider. Hermes is
configured to read the same directory through `skills.external_dirs`.

## Apply and verify

```sh
chezmoi update
exec zsh                    # use exec bash on a Bash-first host
agent-stack-doctor
```

The doctor prints only paths, versions, and non-secret coordination settings.
It never shows authentication stores or configuration values unrelated to this
stack.

Useful bootstrap controls:

| Variable | Effect |
|---|---|
| `SKIP_AGENT_TOOLS=1` | Skip the complete pinned runtime installer |
| `SKIP_HERMES_AGENT=1` | Install Beads, OMP, and Pi and persist Hermes as outside this host profile |
| `SKIP_HERMES_CONFIG_MERGE=1` | Install Hermes but leave a separately managed config untouched |
| `AGENT_TOOLS_ROOT=/path` | Override the versioned runtime root for testing |
| `AGENT_BIN_DIR=/path` | Override managed symlinks for testing |

Containers are skipped by default. WSL is treated as Linux and everything is
installed in the WSL home, never `/mnt/c`. Beads, OMP, and Pi publish all four
macOS/Linux ARM64/x86-64 variants. Hermes' documented Tier-1 desktop support is
macOS Apple Silicon plus Linux/WSL2 ARM64 or x86-64; use
`SKIP_HERMES_AGENT=1` on an unsupported Intel Mac. The doctor treats that host
as a supported partial profile rather than reporting a false failure. A skip is
recorded under `~/.local/share/agent-tools/hermes/.skip-profile`; a later apply
without the skip removes the marker and restores Hermes validation.

## Beads operating rules

Beads is installed, but no repository is initialized automatically. Current
`bd init` defaults can add hooks, inject agent instructions, stage files, and
attempt a commit. Anonymous usage metrics are also enabled by default in Beads
1.1.2. This stack runs `bd metrics off`, exports `BD_DISABLE_METRICS=1`, and
keeps initialization explicit. See the tagged
[init implementation](https://github.com/gastownhall/beads/blob/v1.1.2/cmd/bd/init.go)
and [metrics configuration](https://github.com/gastownhall/beads/blob/v1.1.2/internal/metrics/userconfig.go).

For an approved local pilot that should not add tracked project files or hooks:

```sh
BD_DISABLE_METRICS=1 bd init --stealth --skip-hooks --skip-agents --non-interactive
```

Stealth mode still writes `.git/info/exclude`. Use an external `BEADS_DIR` if
even that local Git change is unwanted.

Every concurrent worker must use a distinct identity:

```sh
agent-bd omp worker-01 -- ready --claim --json
agent-bd pi worker-02 -- ready --claim --json
agent-bd hermes worker-03 -- ready --claim --json
```

The wrapper derives an auditable actor from user, host, harness, and worker ID.
Do not reuse a live worker ID.

### Same host and multiple hosts

- Embedded Beads is file-locked and single-writer. It is fine for a small,
  supervised queue but not optimal for many concurrent writers.
- On one trusted host, use the documented [Dolt server
  mode](https://github.com/gastownhall/beads/blob/v1.1.2/docs/DOLT.md) so all
  workers claim against one shared database.
- Separate hosts that pull and push their own replicas are not one globally
  atomic dispatcher. Their views can be stale. Partition work by host or route
  all claims through one authoritative service.
- `bd dolt push`/`pull` are the canonical versioned synchronization path.
  Exported JSONL is interchange, not a distributed claim protocol.
- Coordinate Beads upgrades across all workers because releases can migrate the
  database schema. Follow the tagged [upgrade
  guidance](https://github.com/gastownhall/beads/blob/v1.1.2/docs/UPGRADING.md)
  before bumping the pin.

## Harness-specific boundaries

- **OMP:** keep task isolation enabled in `workspace-configs`. Upstream supports
  adaptive `task.isolation.mode: auto` with `merge: patch`; the current
  repository-specific configuration may intentionally choose another isolated
  mode. See [OMP task isolation](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md).
- **Pi:** Pi has no built-in workspace isolation or multi-agent scheduler. Run
  it only inside a provisioned worktree, clone, or container. The shared skill
  supplies coordination procedure, not isolation.
- **Hermes:** the installer preserves the existing `~/.hermes/config.yaml` and
  merges only `worktree: true`, `worktree_sync: true`,
  `skills.external_dirs`, and `skills.write_approval: true`. See the upstream
  [worktree](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/git-worktrees.md)
  and [skills](https://github.com/NousResearch/hermes-agent/blob/main/website/docs/user-guide/features/skills.md)
  documentation. If `config.yaml` is a symlink into `workspace-configs`, the
  merge refuses to replace it. Add those four values to that repository and
  apply with `SKIP_HERMES_CONFIG_MERGE=1`.
- **Codex:** full user instructions and settings remain in `workspace-configs`;
  the shared skill is discovered from `~/.agents/skills` without duplicating it.

Never put auth files, tokens, sessions, agent databases, caches, pairing state,
or vector-memory contents in chezmoi.

## Tools deliberately not bootstrapped

| Tool | Verified status | Decision |
|---|---|---|
| [Hindsight](https://github.com/vectorize-io/hindsight/releases/tag/v0.9.0) | 0.9.0; generic integration auto-retains sessions, server mode defaults to cloud, and the current harness list does not cover OMP/Pi/Hermes | Opt-in experiment only. Hermes already has `hermes memory setup`; pin `HINDSIGHT_EMBED_VERSION=0.9.0` if piloted locally. |
| [MCP Agent Mail](https://github.com/Dicklesworthstone/mcp_agent_mail/releases/tag/v0.3.2) | 0.3.2 installer is unpinned and broadly mutates shell/agent config; tagged startup expects an `am` binary its release installer does not provide | Lab evaluation only; never run its bootstrap from chezmoi. |
| [Jujutsu](https://github.com/jj-vcs/jj/releases/tag/v0.44.0) | 0.44.0; improves change and history ergonomics but still needs separate physical working copies | Opt-in per-repository experiment; do not install fleet-wide or auto-initialize repositories. |
| [hmans/beans](https://github.com/hmans/beans/releases/tag/v0.4.2) | 0.4.2, Go plus Markdown/YAML `.beans` files | Simple human-readable backlog, but no reliable concurrent claim authority. |
| [magic-beans](https://github.com/henriquebastos/beans/releases/tag/v0.7.0) | 0.7.0, Python plus SQLite. This is the project referenced by the supplied X post, not hmans/beans. | Same-host ledger only; claim uses a read/check/write race and journal replay is not an offline merge protocol. |

These tools may be reevaluated, but memory, messaging, and a Kanban UI remain
adjacent capabilities. None should displace a transactional task ledger or
isolated source workspace without concurrency tests.

## Upgrade procedure

1. Read the upstream release notes and inspect installer/config migrations.
2. Update versions, commits, asset URLs, and all four architecture checksums in
   `scripts/run_after_20_agent_tools.tmpl`.
3. Exercise the installer with temporary `AGENT_TOOLS_ROOT` and
   `AGENT_BIN_DIR` values, with Hermes skipped.
4. Validate the skill and run all repository checks.
5. Apply to one host, start a fresh shell, and run `agent-stack-doctor`.
6. For a Beads bump, stop writers and complete the coordinated database upgrade
   before applying to the rest of the fleet.
7. Update the version table and date in this document.

Do not use `omp update`, `pi update`, or `hermes update` on individual hosts;
the chezmoi pins are the update authority.
