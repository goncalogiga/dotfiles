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
