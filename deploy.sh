#!/bin/bash
set -e
source "$(dirname "$0")/../server.conf"
REMOTE_PATH=/opt/bitnami/wordpress/hub/
chmod 600 "$SSH_KEY" 2>/dev/null || true

echo "Deploying Hub to $SERVER_IP:$REMOTE_PATH ..."
rsync -avz -e "ssh -i $SSH_KEY" "$(dirname "$0")/index.html" "$SERVER_USER@$SERVER_IP:$REMOTE_PATH"
echo "Done."
