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
nvm use 17
npm install --location=global npm yarn
# Définissez la chaîne de recherche par défaut
# Récupération de la version à remplacer à partir du premier paramètre
new_version=$1
# Vérification si la variable est vide
if [ -z "$new_version" ]; then
  # Si la variable est vide, on définit une valeur par défaut
 new_version="4.9.2"
fi
old_version=$(jq -r '.dependencies."@strapi/strapi"' package.json)
echo "old_version found" $old_version
search_string="$old_version"

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
   
  echo "package.json updated"

  # reinstaller les packages 
  echo "INSTALL NEW PACKAGES"
  pnpm i --shamefully-hoist --fix-lockfile -P 
  #yarn

  # rebuild strapi
  ./build.sh
  
  pnpm build
  # yarn build
  
  # restart server
  ./start.sh
else
  echo "The server will not be updated."
fi
