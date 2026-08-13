# Setting up sbx for vibe

Runs Mistral Vibe inside an isolated microVM. The agent gets its own
filesystem, network, and Docker daemon.

## Requirements

- macOS Sonoma (14) or later, Apple silicon
- sbx 0.36 or later (kits v2 schema)
- A Mistral API key from https://console.mistral.ai

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

## Store the API key

```bash
sbx secret set mistral -t "sk-..."
```

The key stays on your host. The proxy injects it into requests to
`api.mistral.ai`. It never enters the sandbox.

## Run

```bash
cd ~/my-project
sbx run --kit "$DOTFILES_PATH/sbx/vibe"
```

First run asks for a default network policy. Pick **Balanced**.

First run is slow: it pulls the base image, installs uv, then installs
`mistral-vibe`.

## Daily use

```bash
sbx ls                    # list sandboxes
sbx stop <name>           # stop, keep state
sbx rm <name>             # delete
sbx                       # interactive dashboard
```

Name a sandbox so you can come back to it:

```bash
sbx run --kit "$DOTFILES_PATH/sbx/vibe" --name myproj
```

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

## Troubleshooting

Sandbox starts but vibe is missing — check the install step ran:

```bash
sbx exec <name> which vibe
sbx exec <name> vibe --version
```

Vibe hangs at startup — it may be waiting on a trust prompt. Projects
containing a committed `.vibe/` directory trigger this.

API calls fail — check the secret exists and the domain is allowed:

```bash
sbx secret ls
sbx policy ls
```
