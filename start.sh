#/usr/bin/env bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
chmod u+w .env
# load .env variables
source .env
# Prompt for NODE_VERSION if not set
if [ -z "$NODE_VERSION" ]; then  
  echo "## Set NODE_VERSION"
  read -p "NODE_VERSION: " NODE_VERSION
  echo "NODE_VERSION='$NODE_VERSION'"
  echo "NODE_VERSION='${NODE_VERSION//\'/\\\'}'" >> .env
fi
nvm use $NODE_VERSION
NODE_ENV=development
pm2 update
pm2 start ecosystem.config.js -f --exp-backoff-restart-delay=100
pm2 save
echo "server started"
