#/usr/bin/env bash

##
# Strapi tools install script 
#
# This script has no parameters
# The script:
# => set nvm bash completion script
# => set node to the adequate version 
# => check if pm2 is installed 
# => if not:
#   install pm2@latest
#   run pm2 setup
# => then:
#   copy ecosystem.config in root directory
#   copy build.sh , start.sh, upgrade.sh in root directory
##

## set nvm bash completion script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

## set node version
nvm use 17

## check if pm2 is installed
pm2 -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
  ## install pm2@latest
  npm install --location=global pm2@latest

  ## run pm2 setup
  pm2 setup
  exit 1
fi

## copy ecosystem.config in root directory
cp -r ecosystem.config ../.

## copy build.sh , start.sh, upgrade.sh in root directory
cp -r build.sh ../.
cp -r start.sh ../.
cp -r upgrade.sh ../.


## rebuild strapi
./build.sh

## restart server
./start.sh

