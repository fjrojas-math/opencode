#!/usr/bin/env python3
"""
Usage examples (copy & paste):

1. Full flow (gets and prints both tokens):
   python3 scripts/copilot_token_flow.py --authorize [--copy]

2. Refresh only the copilot token using an argument:
   python3 scripts/copilot_token_flow.py --refresh YOUR_ACCESS_TOKEN [--copy]

3. Refresh only the copilot token using an environment variable:
   export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
   python3 scripts/copilot_token_flow.py --refresh [--copy]

After any of these commands, you will see:
  export COPILOT_ACCESS_TOKEN=...  and  export COPILOT_TOKEN=...
If you use --copy, the copilot token will be copied to your clipboard (if supported).
You can copy-paste these lines or use:
  eval $(python3 scripts/copilot_token_flow.py --refresh ...)
to export them directly in your shell.
"""

import sys
import os
import time
import json
import base64
import urllib.request
import urllib.parse
import urllib.error
import subprocess

CLIENT_ID = "Iv1.b507a08c87ecfe98"
DEVICE_CODE_URL = "https://github.com/login/device/code"
ACCESS_TOKEN_URL = "https://github.com/login/oauth/access_token"
COPILOT_TOKEN_URL = "https://api.github.com/copilot_internal/v2/token"

def print_help():
    print("""
Usage: copilot_token_flow.py [--authorize | --refresh <access_token>] [--copy]
  --authorize           Run full Device Flow and get both tokens.
  --refresh <token>     Refresh the copilot token using a valid access token (argument or COPILOT_ACCESS_TOKEN env var).
  --copy                Copy the copilot token to clipboard if possible.
  --help                Show this help.

By default, if no argument is passed, the script will refresh the copilot token using the COPILOT_ACCESS_TOKEN environment variable.

Quick example:
  export COPILOT_ACCESS_TOKEN=YOUR_ACCESS_TOKEN
  python3 scripts/copilot_token_flow.py --copy

NOTE: To export the variables in your shell, use:
  eval $(python3 scripts/copilot_token_flow.py)
    """)

def request_device_code():
    data = urllib.parse.urlencode({
        'client_id': CLIENT_ID,
        'scope': 'read:user,read:org'
    }).encode()
    req = urllib.request.Request(DEVICE_CODE_URL, data=data, headers={'Accept': 'application/json'})
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)

def poll_for_access_token(device_code, interval):
    while True:
        payload = json.dumps({
            'client_id': CLIENT_ID,
            'device_code': device_code,
            'grant_type': 'urn:ietf:params:oauth:grant-type:device_code'
        }).encode()
        req = urllib.request.Request(ACCESS_TOKEN_URL, data=payload, headers={
            'Accept': 'application/json',
            'Content-Type': 'application/json'
        })
        with urllib.request.urlopen(req) as resp:
            data = json.load(resp)
        access_token = data.get('access_token')
        if access_token:
            return access_token
        time.sleep(interval)

def get_copilot_token(access_token):
    req = urllib.request.Request(COPILOT_TOKEN_URL, headers={
        'Authorization': f'token {access_token}',
        'User-Agent': 'vscode/1.89.1'
    })
    try:
        with urllib.request.urlopen(req) as resp:
            data = json.load(resp)
    except urllib.error.HTTPError as e:
        print(f"Error: Could not get copilot token. HTTP {e.code} {e.reason}. Is the access token valid?", file=sys.stderr)
        sys.exit(1)
    token = data.get('token')
    if not token:
        print("Error: Could not get copilot token. Is the access token valid?", file=sys.stderr)
        sys.exit(1)
    return token

def decode_jwt_payload(jwt_token):
    try:
        payload_b64 = jwt_token.split('.')[1]
        # Pad base64 if needed
        payload_b64 += '=' * (-len(payload_b64) % 4)
        payload_bytes = base64.urlsafe_b64decode(payload_b64)
        try:
            # Try to decode as JSON
            return json.loads(payload_bytes.decode('utf-8'))
        except Exception as e:
            print(f"Warning: Could not decode JWT payload as JSON: {e}", file=sys.stderr)
            print("Raw decoded payload (bytes):", file=sys.stderr)
            print(payload_bytes, file=sys.stderr)
            return None
    except Exception as e:
        print(f"Error decoding JWT: {e}", file=sys.stderr)
        return None

def copy_to_clipboard(token):
    # Try xclip (X11)
    if shutil.which('xclip') and os.environ.get('DISPLAY'):
        try:
            p = subprocess.Popen(['xclip', '-selection', 'clipboard'], stdin=subprocess.PIPE)
            p.communicate(input=token.encode())
            if p.returncode == 0:
                print("Copilot token copied to clipboard (xclip).")
                return
        except Exception:
            pass
    # Try wl-copy (Wayland)
    if shutil.which('wl-copy') and os.environ.get('WAYLAND_DISPLAY'):
        try:
            p = subprocess.Popen(['wl-copy'], stdin=subprocess.PIPE)
            p.communicate(input=token.encode())
            if p.returncode == 0:
                print("Copilot token copied to clipboard (wl-copy).")
                return
        except Exception:
            pass
    # Fallback: print token for manual copy
    print("Warning: No clipboard tool found or no graphical session detected.")
    print("Copy this token manually:")
    print(token)

import shutil

def main():
    args = sys.argv[1:]
    # Detect --copy flag and remove it from args
    copy_flag = False
    filtered_args = []
    for arg in args:
        if arg == '--copy':
            copy_flag = True
        else:
            filtered_args.append(arg)
    args = filtered_args

    if not args or args[0] == '--help':
        # --- New default: refresh token using env var if no args ---
        if not args:
            access_token = os.environ.get('COPILOT_ACCESS_TOKEN')
            if not access_token:
                print("Error: No access token provided and COPILOT_ACCESS_TOKEN environment variable is not set.", file=sys.stderr)
                print_help()
                return
            copilot_token = get_copilot_token(access_token)
            print(f"Copilot token obtained: {copilot_token}")
            print("Copilot token payload (JWT):")
            payload = decode_jwt_payload(copilot_token)
            print(json.dumps(payload, indent=2))
            print(f"export COPILOT_ACCESS_TOKEN='{access_token}'")
            print(f"export COPILOT_TOKEN='{copilot_token}'")
            if copy_flag:
                copy_to_clipboard(copilot_token)
            return
        # --- End new default ---
        print_help()
        return

    if args[0] == '--authorize':
        # Step 1: Request device code
        resp = request_device_code()
        device_code = resp['device_code']
        user_code = resp['user_code']
        verification_uri = resp['verification_uri']
        interval = int(resp['interval'])
        print(f"Open {verification_uri} and enter the code: {user_code}")
        input("Press Enter after authorizing the device...")
        # Step 2: Poll for access token
        access_token = poll_for_access_token(device_code, interval)
        print(f"Access token obtained: {access_token}")
        # Step 3: Get copilot token
        copilot_token = get_copilot_token(access_token)
        print(f"Copilot token obtained: {copilot_token}")
        # Step 4: Decode JWT
        print("Copilot token payload (JWT):")
        payload = decode_jwt_payload(copilot_token)
        print(json.dumps(payload, indent=2))
        # Step 5: Print export lines
        print(f"export COPILOT_ACCESS_TOKEN='{access_token}'")
        print(f"export COPILOT_TOKEN='{copilot_token}'")
        if copy_flag:
            copy_to_clipboard(copilot_token)
        return

    if args[0] == '--refresh':
        if len(args) > 1:
            access_token = args[1]
        else:
            access_token = os.environ.get('COPILOT_ACCESS_TOKEN')
            if not access_token:
                print("Error: Provide the access token as argument or set COPILOT_ACCESS_TOKEN env var.", file=sys.stderr)
                print_help()
                return
        copilot_token = get_copilot_token(access_token)
        print(f"Copilot token obtained: {copilot_token}")
        print("Copilot token payload (JWT):")
        payload = decode_jwt_payload(copilot_token)
        print(json.dumps(payload, indent=2))
        print(f"export COPILOT_ACCESS_TOKEN='{access_token}'")
        print(f"export COPILOT_TOKEN='{copilot_token}'")
        if copy_flag:
            copy_to_clipboard(copilot_token)
        return

    print(f"Unknown argument: {args[0]}")
    print_help()

if __name__ == "__main__":
    main()
