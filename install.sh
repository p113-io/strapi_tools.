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
# and if API_NAME and NODE_VERSION are set, 
# if not, prompt for NODE_VERSION value and for API_NAME value 
# and write the values to the .env file
##
# Check if .env file exists and load variables
## set .env permissions to be writenable
chmod u+w ../.env
if [ -f ../.env ]; then
  source ../.env
  
  # Prompt for API_NAME if not set
  if [ -z "$API_NAME" ]; then
    echo "## Set API_NAME"
    read -p "API_NAME: " API_NAME
    echo "API_NAME='$API_NAME'"
    echo "API_NAME='${API_NAME//\'/\\\'}'" >> ../.env
  fi

  # Prompt for NODE_ENV if not set
  if [ -z "$NODE_ENV" ]; then
    echo "## Set NODE_ENV"
    read -p "NODE_ENV: [development or production]" NODE_ENV
    echo "NODE_ENV='$NODE_ENV'"
    echo "NODE_ENV='${NODE_ENV//\'/\\\'}'" >> ../.env
  fi
  
  # Prompt for NODE_VERSION if not set
  if [ -z "$NODE_VERSION" ]; then  
    echo "## Set NODE_VERSION"
    read -p "NODE_VERSION: " NODE_VERSION
    echo "NODE_VERSION='$NODE_VERSION'"
    echo "NODE_VERSION='${NODE_VERSION//\'/\\\'}'" >> ../.env
  fi
else
  # Prompt for API_NAME and NODE_VERSION if .env file does not exist
  echo "## Set API_NAME and NODE_VERSION"
  read -p "API_NAME: " API_NAME
  read -p "NODE_VERSION: " NODE_VERSION
  echo "API_NAME='$API_NAME'"
  echo "NODE_VERSION='$NODE_VERSION'"
  echo "API_NAME='${API_NAME//\'/\\\'}'" >> ../.env
  echo "NODE_VERSION='${NODE_VERSION//\'/\\\'}'" >> ../.env
  echo "## Set NODE_ENV"
  read -p "NODE_ENV: [development or production]" NODE_ENV
  echo "NODE_ENV='$NODE_ENV'"
  echo "NODE_ENV='${NODE_ENV//\'/\\\'}'" >> ../.env
fi

# Reload .env variables
source ../.env

echo "## Set \n node version to "$NODE_VERSION" ,\n  API_NAME to "$API_NAME",\n NODE_ENV to "$NODE_ENV" \n  in .env file" 
## set node version
nvm use $NODE_VERSION

echo "## check if yarn is installed"
## check if yarn is installed
yarn -v > /dev/null 2>&1
if [ $? -ne 0 ]; 
then
  echo "## install yarn"
  ## install pm2@latest
  npm install --location=global yarn
  exit 1
fi

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
## copy ecosystem.config in root directory
cp ecosystem.config.js ../ecosystem.config.js

## modify ecosystem.config name parameter to API_NAME
# Chemin vers le fichier javascript
file_path="../ecosystem.config.js"

## champ name 
# Trouver la ligne qui contient le champ "name"
line_number=$(grep -n "name:" $file_path | cut -d: -f1)
# Extraire la ligne contenant la propriété "name" du fichier javascript
line_number=$(grep -n "name:" $file_path | cut -d ":" -f 1)
current_name=$(grep "name:" $file_path | awk -F "[,:]" '{print $2}' | sed 's/^ *//;s/ *$//')

echo "current_name: "$current_name
# Remplacer la valeur actuelle par la nouvelle valeur
sed -i "${line_number}s/${current_name}/'${API_NAME}'/" $file_path
# Afficher le résultat
echo "## name field updated with: " $API_NAME

## champ NODE_ENV 
# Trouver la ligne qui contient le champ "args"
node_line_number=$(grep -n "args:" $file_path | cut -d: -f1)
# Extraire la ligne contenant la propriété "args" du fichier javascript
node_line_number=$(grep -n "args:" $file_path | cut -d ":" -f 1)
node_env=$(grep "args:" $file_path | awk -F "[,:]" '{print $2}' | sed 's/^ *//;s/ *$//')

echo "node_env: "$node_env
# Remplacer la valeur actuelle par la nouvelle valeur
sed -i "${node_line_number}s/${node_env}/'${NODE_ENV}'/" $file_path
# Afficher le résultat
echo "## node_version field updated with: " $NODE_VERSION

## copy other scripts in Strapi root directory
echo "## copy build.sh , start.sh, upgrade.sh in Strapi root directory"
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