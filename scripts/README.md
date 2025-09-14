# Copilot Token Flow Scripts

This directory contains two scripts to easily obtain and refresh your GitHub Copilot token on Linux:

- `copilot_token_flow.sh` (Bash, compatible with bash and zsh)
- `copilot_token_flow.py` (Python 3, no external dependencies)

---

## Quick usage (automatic refresh)

If you already have a GitHub Copilot access token, simply export the variable and run the script:

### Bash

```bash
export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
source scripts/copilot_token_flow.sh --copy
```

### Python

```bash
export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
python3 scripts/copilot_token_flow.py --copy
```

This will refresh the copilot token and copy it to your clipboard if you have `xclip` or `wl-copy` and a graphical session.

---

## Full authorization flow (Device Flow)

If you don't have an access token, you can obtain it and refresh the copilot token in one step:

### Bash

```bash
source scripts/copilot_token_flow.sh --authorize --copy
```

### Python

```bash
python3 scripts/copilot_token_flow.py --authorize --copy
```

Follow the on-screen instructions: open the URL, enter the code, authorize, and press Enter. The script will display both tokens and copy the copilot token to your clipboard if possible.

---

## Available options

- `--authorize` Runs the full Device Flow and obtains both tokens.
- `--refresh <token>` Refreshes the copilot token using an access token (argument or environment variable).
- `--copy` Copies the copilot token to the clipboard if possible.
- `--help` Shows help.

> **Note:** If no argument is passed, both scripts refresh the copilot token using the `COPILOT_ACCESS_TOKEN` environment variable.

---

## Exporting variables in your shell

- In bash, if you use `source`, the variables are exported automatically.
- In python, you can use:
  ```bash
  eval $(python3 scripts/copilot_token_flow.py --copy)
  ```

---

## Compatibility and dependencies

- **Bash:** Requires `curl`, `jq`, and optionally `xclip` or `wl-copy` for clipboard support.
- **Python:** Only requires standard Python 3. For clipboard support, needs `xclip` or `wl-copy` and a graphical session.
- Both scripts work on standard Linux and are compatible with bash and zsh.

---

## Example output

```
Copilot token obtained: ghc_xxx...
Copilot Token Payload (JWT):
{
  "exp": 1700000000,
  ...
}
Exported variables: COPILOT_TOKEN and COPILOT_ACCESS_TOKEN (if applicable)
Copilot token copied to clipboard (xclip).
```

---

Questions or issues? Open an issue or check each script's help with `--help`.
