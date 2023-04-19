#/usr/bin/env bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
nvm use 17
NODE_ENV=development
pm2 update
pm2 start ecosystem.config.js -f --exp-backoff-restart-delay=100
pm2 save
echo "server started"
