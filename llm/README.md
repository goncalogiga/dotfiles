# llm

Shell helpers for launching LLM coding sandboxes.

## Setup

Source `llm.sh` in your `.bashrc` or `.zshrc`:

```shell
export DOTFILES_PATH=<THIS_REPO_PATH>
[ -f "$DOTFILES_PATH/llm/llm.sh" ] && . "$DOTFILES_PATH/llm/llm.sh"
```

Add your Mistral API key to sandboxes:

```shell
sbx secret set-custom --host api.mistral.ai --env MISTRAL_API_KEY --value "$MISTRAL_API_KEY"
```

## Commands

### Direct mode

Launch a sandbox in a directory (default: current directory). Reuses the sandbox if it already exists.

| Command | Description |
|---------|-------------|
| `vibe [dir]` | Launch a Vibe sandbox. |
| `pi [dir]` | Launch a Pi sandbox. |

### Worktree mode

`vibetree` manages feature worktrees with their own sandboxes. Without
arguments it shows an interactive menu (requires `fzf`) to pick an existing
feature or create a new one.

```shell
vibetree                            # interactive menu (vibe)
vibetree --harness pi               # interactive menu (pi)
vibetree "my feature"               # new worktree (vibe)
vibetree --harness pi "my feature"  # new worktree (pi)
```

Worktrees are stored in `~/.vibetrees/<repo>/`.

## Gitignored files and secrets

Sandboxes bind-mount the workspace, so everything in it — including
gitignored files — is readable by the agent. Before launching, `llm.sh`
moves gitignored files (e.g. `decrypted/` secrets, `.venv/`) out of the
workspace into `~/.vibetrees/stash/<id>/` and restores them when the
sandbox exits. Nothing is deleted; a leftover stash from a killed shell
is recovered automatically on the next launch.

* Set `SBX_STASH_IGNORED=0` to disable.
* Set `SBX_STASH_ROOT` to change the stash location (must be outside the
  workspace).

Caveats:

* The `.git` directory is still mounted: anything ever committed is
  readable, including history. Only commit encrypted secrets.
* SSH agent forwarding is enabled by default in Docker Sandboxes: the
  agent can use your host SSH keys even though the key files are stashed.
  Unset `SSH_AUTH_SOCK` before launching to disable it.
* The `MISTRAL_API_KEY` is injected by the sbx proxy and is never visible
  inside the sandbox.
