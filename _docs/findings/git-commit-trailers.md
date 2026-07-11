# _docs/findings/git-commit-trailers.md
# Records unexpected `Co-authored-by` lines appearing in commits on macOS.
# Does not prescribe editor settings; only documents what we observed and a workaround.

## Symptom

`git commit` or `git commit --amend` can leave a `Co-authored-by: …` trailer in the message even when you only pass `-m` flags or a message file that does not contain that line.

## Cause (local)

On at least one Apple Silicon setup, `/opt/homebrew/bin/git` (Homebrew’s first-on-PATH `git`) rewrote the commit message after `git` ran. The same amendment with `/usr/bin/git` (Apple Git from the Command Line Tools) produced a clean message.

## Workaround

- Prefer `/usr/bin/git` when amending or creating commits that must not carry extra trailers, **or**
- Put `/usr/bin/git` ahead of `/opt/homebrew/bin` on `PATH` for terminal sessions where you commit.

## Clean up an existing commit

```bash
/usr/bin/git commit --amend …   # pass the intended message only; omit --no-edit if you use -m
```

Re-verify with `git cat-file -p HEAD` (message body is the text after the header block).
