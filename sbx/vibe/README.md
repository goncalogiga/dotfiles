# Setting up sbx for vibe

Runs Mistral Vibe inside an isolated microVM. The agent gets its own
filesystem, network, and Docker daemon.

## Requirements

- macOS Sonoma (14) or later, Apple silicon
- sbx 0.36 or later (kits v2 schema)

## Install sbx

```bash
brew trust docker/tap
brew install docker/tap/sbx
sbx login
```

`sbx login` opens a browser. Sign in with your Docker account.

Check the version:

```bash
sbx version
```

## Run

```bash
cd ~/my-project
sbx run --kit "$DOTFILES_PATH/sbx/vibe" vibe .
```

Arguments: `--kit <path>`, then the agent name (`vibe`, matching `name:`
in spec.yaml), then the workspace path.

First run asks for a default network policy. Pick **Balanced**.

First run is slow: it pulls the base image, installs uv, then installs
`mistral-vibe`.

## API key

The kit does not manage credentials. On first launch vibe runs its setup
wizard — paste a key from https://chat.mistral.ai/code/extensions
(Code › Vibe CLI). Keys from console.mistral.ai will not work.

The key is saved to `~/.vibe/.env` inside the sandbox. It survives stop
and re-attach, but not `sbx rm`. Each new sandbox needs it again.

## Daily use

```bash
sbx ls                    # list sandboxes
sbx stop <name>           # stop, keep state
sbx rm <name>             # delete
sbx                       # interactive dashboard
```

Create a named sandbox, then reattach to it later:

```bash
sbx create --name myproj --kit "$DOTFILES_PATH/sbx/vibe" vibe .
sbx run --kit "$DOTFILES_PATH/sbx/vibe" --name myproj
```

Pass `--kit` again when re-running an existing sandbox.

## Network

The kit allows only these domains:

- `api.mistral.ai` — the model API
- `astral.sh`, `github.com`, `objects.githubusercontent.com` — uv installer
- `pypi.org`, `files.pythonhosted.org` — the vibe package

Anything else is blocked. To allow more:

```bash
sbx policy allow network registry.npmjs.org
sbx policy ls
```

## Files

```
sbx/vibe/
├── spec.yaml                      # the kit
└── files/home/.vibe/config.toml   # copied to /home/agent/.vibe/
```

Edit `spec.yaml` to change the image, network rules, or install steps.
Edit `config.toml` to change vibe settings.

Changes to `spec.yaml` only apply to new sandboxes. Recreate to pick
them up:

```bash
sbx rm <name> && sb vibe
```

## Troubleshooting

Sandbox starts but vibe is missing — check where the symlink points. The
agent runs as uid 1000 and cannot read root's home:

```bash
sbx exec <name> -- ls -la /usr/local/bin
sbx exec <name> -- vibe --version
```

Vibe hangs at startup — it may be waiting on a trust prompt. Projects
containing a committed `.vibe/` directory trigger this.

Invalid API key — the key is from console.mistral.ai rather than
Code › Vibe CLI. Rerun `vibe --setup` inside the sandbox.
