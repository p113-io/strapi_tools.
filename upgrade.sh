#!/usr/bin/env bash
##
# Strapi Upgrade script
#
# this script can optionally take one parameter
# ./upgrade.sh 4.9.2
# the parameter is tne new version we want for the Strapi
# new_version=$1
# if the parameter is not set , the script will later prompt for a version number
##
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# set .env permissions for writing
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
# Set node version
nvm use $NODE_VERSION

# update yarn and pm2
npm install --location=global yarn pm2@latest

# Définissez la chaîne de recherche par défaut old_version
old_version=$(jq -r '.dependencies."@strapi/strapi"' package.json)
echo "old_version found" $old_version
search_string="$old_version"

# Récupération de la version à remplacer à partir du premier paramètre
new_version=$1
if [[ $new_version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; 
then
  echo "La version $new_version est au bon format (x.x.x)."
else
  echo "La version $new_version n'est pas au bon format (x.x.x)."
fi
# Vérification si la variable est vide
if [ -z "$new_version" ]; 
then
  # Si la variable est vide, on définit une valeur par défaut
 new_version="4.9.2"
  # Définissez la nouvelle chaîne de remplacement par défaut
 replace_string=$new_version
 read -p "Do you want to update the server (yes/no)? " choice

  if [ "$choice" == "yes" ]; then
    # Demandez la chaîne de recherche, utilisez la valeur par défaut si aucune entrée n'est fournie
    read -p "Enter the search string (default: $search_string): " input
    search_string=${input:-$search_string}

    # Demandez la nouvelle chaîne de remplacement, utilisez la valeur par défaut si aucune entrée n'est fournie
    read -p "Enter the replace string (default: $replace_string): " input
    replace_string=${input:-$replace_string}

    # Exécutez le remplacement
    sed -i "s/${search_string}/${replace_string}/g" package.json
  else
    echo "The server will not be updated."
  fi
else
  # pas besoin de prompts on peut l'utiliser pour upgrader le strapi
  replace_string=$new_version
   # Exécutez le remplacement
  sed -i "s/${search_string}/${replace_string}/g" package.json   
fi
echo "package.json updated"

# rebuild strapi
./build.sh

# restart server
./start.sh



