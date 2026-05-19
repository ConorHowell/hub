#!/bin/bash
set -e
SERVER_USER=bitnami
SERVER_IP=52.13.231.223
SSH_KEY=~/.ssh/LightsailDefaultKey-us-west-2.pem
REMOTE_PATH=/opt/bitnami/wordpress/hub/

echo "Deploying Hub to $SERVER_IP:$REMOTE_PATH ..."
scp -i "$SSH_KEY" index.html "$SERVER_USER@$SERVER_IP:$REMOTE_PATH"
echo "Done."
