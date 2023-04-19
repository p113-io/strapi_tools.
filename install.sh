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

##
# check if 
# ../.env file exists 
# and if apiName and nodeVersion are set, 
# if not, prompt for nodeVersion value and for apiName value 
# and write the values to the .env file
##
# Check if .env file exists and load variables
if [ -f ../.env ]; then
  ## set .env permissions to be writenable
  chmod u+w ../.env
  source ../.env
  
  # Prompt for apiName if not set
  if [ -z "$apiName" ]; then
    echo "## Set apiName"
    read -p "apiName: " apiName
    echo "apiName='$apiName'"
    echo "apiName='${apiName//\'/\\\'}'" >> ../.env
  fi
  
  # Prompt for nodeVersion if not set
  if [ -z "$nodeVersion" ]; then  
    echo "## Set nodeVersion"
    read -p "nodeVersion: " nodeVersion
    echo "nodeVersion='$nodeVersion'"
    echo "nodeVersion='${nodeVersion//\'/\\\'}'" >> ../.env
  fi
else
  # Prompt for apiName and nodeVersion if .env file does not exist
  echo "## Set apiName and nodeVersion"
  read -p "apiName: " apiName
  read -p "nodeVersion: " nodeVersion
  echo "apiName='$apiName'"
  echo "nodeVersion='$nodeVersion'"
  echo "apiName='${apiName//\'/\\\'}'" >> ../.env
  echo "nodeVersion='${nodeVersion//\'/\\\'}'" >> ../.env
fi

# Reload .env variables
source ../.env

echo "## Set node version to "$nodeVersion" and apiName to "$apiName" in .env file" 
## set node version
nvm use $nodeVersion

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

## modify ecosystem.config name parameter to apiName
# Chemin vers le fichier javascript
file_path="ecosystem.config.js"

# Trouver la ligne qui contient le champ "name"
line_number=$(grep -n "name:" $file_path | cut -d: -f1)

# Extraire la valeur actuelle du champ "name"
current_name=$(grep "name:" $file_path | awk '{print $2}' | tr -d ',')

# Remplacer la valeur actuelle par la nouvelle valeur
sed -i "${line_number}s/${current_name}/${apiName}/" $file_path

# Afficher le résultat
echo "## name field updated with: " $apiName

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