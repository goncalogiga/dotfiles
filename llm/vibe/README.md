# sbx-vibe

To add the custom vibe command, insert this lines in the `.bashrc`:

```shell
export SBX_VIBE_PATH=<THIS_REPO_PATH>
[ -f "$SBX_VIBE_PATH/vibe.sh" ] && . "$SBX_VIBE_PATH/vibe.sh"
```

To add your Mistral API key to docker sandboxes :

```shell
sbx secret set-custom --host api.mistral.ai --env MISTRAL_API_KEY --value "$MISTRAL_API_KEY"
```
