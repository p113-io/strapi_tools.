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

chmod u+w ../.env
if [ -f ../.env ]; then
  source ../.env
  if [ -z "$TRANSFER_TOKEN_SALT" ]; 
  then
    ## add first line comment for Strapi tools in .env
    echo "TRANSFER_TOKEN_SALT=yezFK+Kpa0kFu3TH0CIIOA==" >> ../.env
  fi
  ## Check if DATABASE_CLIENT=mysql
  # Prompt for DATABASE_CLIENT if not set
  if [ -z "$DATABASE_CLIENT" ]; 
  then
    ## add first line comment for Strapi tools in .env
    echo "## Database" >> ../.env
    ## Get DATABASE_CLIENT from ../config/database.js
    echo "DATABASE_CLIENT="$(cat ../config/database.js | grep -E "client" | awk -F "'" '{print $2}') >> ../.env
    
    ## Check if DATABASE_HOST
    if [ -z "$DATABASE_HOST" ]; 
    then
      echo "DATABASE_HOST=127.0.0.1" >> ../.env
    fi
    
    ## Check if DATABASE_PORT
    if [ -z "$DATABASE_PORT" ];
    then
      echo "DATABASE_PORT=3306" >> ../.env
    fi
    
    ## Check if DATABASE_NAME
    if [ -z "$DATABASE_NAME" ];
    then
      ## Get DATABASE_NAME from ../config/database.js
      echo "DATABASE_NAME="$(cat ../config/database.js | grep -E "database" | awk -F "'" '{print $4}') >> ../.env
    fi
    
    ## Check if DATABASE_USERNAME=anima_api
    if [ -z "$DATABASE_USERNAME" ];
    then
      ## Get DATABASE_NAME from ../config/database.js
      echo "DATABASE_USERNAME="$(cat ../config/database.js | grep -E "user" | awk -F "'" '{print $4}') >> ../.env
    fi
    
    ## Check if DATABASE_PASSWORD
    if [ -z "$DATABASE_PASSWORD" ];
    then
      ## Get DATABASE_NAME from ../config/database.js
      echo "DATABASE_PASSWORD="$(cat ../config/database.js | grep -E "password" | awk -F "'" '{print $4}') >> ../.env
    fi

    ## Check if DATABASE_SSL=false
    if [ -z "$DATABASE_SSL" ];
    then
      ## Get DATABASE_SSL from ../config/database.js
      echo "DATABASE_SSL=false" >> ../.env
    fi

    ## Copy new config files
    cp config/database.js ../config/database.js
    cp config/api.js ../config/api.js
    cp config/server.js ../config/server.js
    cp config/admin.js ../config/admin.js
    echo "## New config files added and .env file updated"
  fi

 

  ## Check if first install and then all the .env variables are not set.
  if [[ -z "${API_NAME:-}" && -z "${NODE_ENV:-}" && -z "${NODE_VERSION:-}" ]]; then
    ## add first line comment for Strapi tools in .env
    echo "## Strapi tools" >> ../.env
  fi
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
    echo "NODE_VERSION=${NODE_VERSION//\'/\\\'}" >> ../.env
  fi
  # Vérifie si la variable IS_CLUSTER est définie
  if [[ -z "${IS_CLUSTER}" ]]; then
    # Si la variable n'est pas définie, demander une valeur true ou false avec false par défaut
    read -p "IS_CLUSTER variable is not set. Do you want to set it to true? (y/N): " answer
    if [[ "${answer}" == "y" ]]; then
      IS_CLUSTER=true
    else
      IS_CLUSTER=false
    fi
    echo "IS_CLUSTER='$IS_CLUSTER'"
    echo "IS_CLUSTER=${IS_CLUSTER//\'/\\\'}" >> ../.env
  fi
else
  # Prompt for API_NAME and NODE_VERSION if .env file does not exist
  echo "## Strapi tools" >> ../.env
  echo "## Set API_NAME and NODE_VERSION"
  read -p "API_NAME: " API_NAME
  read -p "NODE_VERSION: " NODE_VERSION
  echo "API_NAME='$API_NAME'"
  echo "NODE_VERSION='$NODE_VERSION'"
  echo "API_NAME='${API_NAME//\'/\\\'}'" >> ../.env
  echo "NODE_VERSION=${NODE_VERSION//\'/\\\'}" >> ../.env
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
if [[ "$node_env" == "production" ]]; 
then
# Remplacer la valeur actuelle par la nouvelle valeur
sed -i "${node_line_number}s/${node_env}/'start'/" $file_path
else
# Remplacer la valeur actuelle par la nouvelle valeur
sed -i "${node_line_number}s/${node_env}/'develop'/" $file_path
fi
# Afficher le résultat
echo "## node_version field updated with: " $NODE_VERSION

if [[ "$IS_CLUSTER" == true ]]; 
then

  ## champ IS_CLUSTER
 
  # Remplacer la valeur actuelle par la nouvelle valeur : IS_CLUSTER=true ? 'cluster': 'fork'
  exec_mode="cluster"
  ## Prompt for INSTANCES if not set
  if [ -z "$INSTANCES" ]; then
    echo "## Set INSTANCES"
    read -p "INSTANCES: [number:2]" INSTANCES
    echo "INSTANCES='$INSTANCES'"
    echo "INSTANCES=${INSTANCES//\'/\\\'}" >> ../.env
  fi
  # Si la variable instances n'est pas définie dans le fichier ecosystem , 
  # on l'ajoute avec une valeur de 2
  if ! grep -q 'instances :' $file_path; 
  then
    sed -i '/apps : [{/a \    instances : "$INSTANCES",' $file_path
  else 

    # sinon on modifie la valeur de instances dans le fichier
    # Extraire la ligne contenant la propriété "instances" du fichier javascript
    instances_line_number=$(grep -n "instances:" $file_path | cut -d ":" -f 1)
    # Remplacer la valeur actuelle par la nouvelle valeur
    sed -i '${instances_line_number}s/${INSTANCES}/${INSTANCES}/' $file_path
  fi
else
  exec_mode="fork"
  # enlever la ligne qui contient le champ "instances"
  if grep -q 'instances :' $file_path; then
    sed -i '/instances :/d' $file_path
  fi
fi
# Trouver la ligne qui contient le champ "exec_mode"
cluster_line_number=$(grep -n "exec_mode:" $file_path | cut -d: -f1)
# Extraire la ligne contenant la propriété "exec_mode" du fichier javascript
cluster_line_number=$(grep -n "exec_mode:" $file_path | cut -d ":" -f 1)
cluster=$(grep "exec_mode:" $file_path | awk -F "[,:]" '{print $2}' | sed 's/^ *//;s/ *$//')
echo "cluster: " $cluster
sed -i '${cluster_line_number}s/${exec_mode}/${exec_mode}/' $file_path

## copy other scripts in Strapi root directory
echo "## copy build.sh , start.sh, upgrade.sh in Strapi root directory"
## copy build.sh , start.sh, upgrade.sh in root directory
cp  build.sh ../.
cp  start.sh ../.
cp  upgrade.sh ../.
cp  server.js ../.

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