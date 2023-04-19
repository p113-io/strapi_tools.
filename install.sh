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
echo "## Load NVM bash_completion"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

echo "## Set node version to 17" 
## set node version
nvm use 17

echo "## check if pm2 is installed"
## check if pm2 is installed
pm2 -v > /dev/null 2>&1
if [ $? -ne 0 ]; 
then
  echo "## install pm2@latest"
  ## install pm2@latest
  npm install --location=global pm2@latest

  echo "## run pm2 setup"
  ## run pm2 setup
  pm2 setup

  exit 1
fi

echo "## copy ecosystem.config in root directory"
## copy ecosystem.config in root directory
cp ecosystem.config.js ../.

echo "## copy build.sh , start.sh, upgrade.sh in root directory"
## copy build.sh , start.sh, upgrade.sh in root directory
cp  build.sh ../.
cp  start.sh ../.
cp  upgrade.sh ../.

echo "## go to root directory"
## go to root directory
cd ../

echo "## build strapi"
## rebuild strapi
./build.sh

echo "## restart pm2 and strapi "
## restart server and empty the pm2 cache
pm2 kill 
pm2 flush
pm2 start ecosystem.config.js 
pm2 save 
./start.sh

echo "## End of the install script"