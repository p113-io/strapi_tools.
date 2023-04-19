#!/usr/bin/env bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
chmod u+w .env
# load .env variables
source .env
# Prompt for API_NAME if not set
# Prompt for NODE_VERSION if not set
if [ -z "$NODE_VERSION" ]; then  
  echo "## Set NODE_VERSION"
  read -p "NODE_VERSION: " NODE_VERSION
  echo "NODE_VERSION='$NODE_VERSION'"
  echo "NODE_VERSION='${NODE_VERSION//\'/\\\'}'" >> .env
fi

nvm use $NODE_VERSION
pnpm add -g pnpm
rm -rf public/uploads/uplink/*
git pull 
# pnpm i --shamefully-hoist --fix-lockfile -P 
# pnpm build
yarn 
yarn build
