#!/bin/bash
set -e
source "$(dirname "$0")/../../server.conf"
REMOTE_PATH="${REMOTE_ROOT:?server.conf not sourced}/hub/"
chmod 600 "$SSH_KEY" 2>/dev/null || true

echo "Deploying Hub to $SERVER_IP:$REMOTE_PATH ..."
# The rsync below carries --delete: an empty or mis-resolved source does not deploy
# nothing -- it erases the live site. Nothing ships without the entry point present.
# (Guard added estate-wide after the champ near-miss; audit 2026-07-30.)
_SRC="$(cd "$(dirname "$0")" && pwd)"
if [ ! -s "$_SRC/index.html" ]; then
  echo "ERROR: $_SRC/index.html missing or empty -- refusing to rsync --delete onto live." >&2
  exit 1
fi

rsync -avz --delete --exclude='.git' --exclude='.github' --exclude='.claude' --exclude='*.code-workspace' \
  --exclude='.DS_Store' --exclude='.gitignore' --exclude='deploy.sh' --exclude='.htaccess' --exclude='.htpasswd' --exclude='docs' -e "ssh -i $SSH_KEY" "$(dirname "$0")/" "$SERVER_USER@$SERVER_IP:$REMOTE_PATH"
echo "Done."
