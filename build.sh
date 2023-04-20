#!/usr/bin/env bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
## Set .env permissions to be writenable
chmod u+w .env

## Load .env variables
source .env

## Prompt for NODE_VERSION if not set
if [ -z "$NODE_VERSION" ]; then  
  echo "## Set NODE_VERSION"
  read -p "NODE_VERSION: " NODE_VERSION
  echo "NODE_VERSION='$NODE_VERSION'"
  echo "NODE_VERSION='${NODE_VERSION//\'/\\\'}'" >> .env
fi
## Prompt for NODE_ENV if not set
if [ -z "$NODE_ENV" ]; then
  echo "## Set NODE_ENV"
  read -p "NODE_ENV: [development or production]" NODE_ENV
  echo "NODE_ENV='$NODE_ENV'"
  echo "NODE_ENV='${NODE_ENV//\'/\\\'}'" >> ../.env
fi

## Set node version
nvm use $NODE_VERSION

## check if storj directory exists and empty it if true
if [ -d "/public/uploads/uplink/" ]; 
then
    rm -rf public/uploads/uplink/*
fi

## Sync Strapi with git directory 
git pull 

## Install or update packages
yarn 
## Build Strapi
yarn build
## End
echo "End Build Script"