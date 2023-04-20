module.exports = {
  apps : [{
    name: 'api.mydomain',
    interpreter: 'node',
    script: 'yarn.js',
    args: 'develop',
    instances : 2,
    exec_mode : 'cluster'
  }],
};
