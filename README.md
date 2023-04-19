## Strapi tools
### v 4.x.x and above only

this is a list of bash scripts used to install, build, start and upgrade the trapi server:
This is intended to be used just after the creation of a new strapi project, but an be added later also

### installation of the package

Go to your Strapi root directory:

In Vesta servers the path looks like this:
```
cd /home/$user/web/api.mydomanio.com/api/
```
where api is the directory that contain strapi

see [how to install strapi from scratch](wiki/how-to-install-strapi) for further info.

Once in your Strapi server root directory, clone this project:

Check that your git directory is sync with your strapi directory
```
```

```
 
git pull && git status && git add . && git commit -m "sync strapi with git directory"
git clone https://git.pulsar113.org/P113/strapi_tools.git tools
cd tools
./install.sh
cd ../
./build.sh
pm2 start ecosystem.config.js 
pm2 save
./start.sh
git add . && git commit -m ""
```

#### Install

* check if pm2 is installed 
* if not
* => install pm2@latest 
* => run pm2 setup
* then 
* => copy ecosystem.config in root directory
* => copy build.sh , start.sh, upgrade.sh in root directory

```
cd tools
./install.sh 

```

#### Build

This is a script that build the administration templates of the strapi server.

The Admin templates have to be rebuild when:

* strapi is updated: manually or using the upgrade script
* a new strapi generate is used to create new:
* => plugin
* => api
* => service
* => ...
* plugin, api , service or any files in directory config is modified 

The script:
* set node version to the adequate value
* update npm, pm2 and yarn to the last version
* execute git pull to update the strapi project 
* execute yarn build to build the templates

```
./build.sh

```

#### Upgrade

This a script to upgrade the strapi server to a new version

The script:
  * set the node version to the adequate value 
  * parse the package.json file to get the current strapi version 
  * check if parameter is used , and if not ask for one
  * replace in package.json the strapi version with the new version
  * execute build.sh to rebuild the admin templates

The script can be used differently:

* With a parameter 
```
./upgrade.sh 4.92
```
* Without parameter
```
./upgrade.sh

```