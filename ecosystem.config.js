module.exports = {
  apps : [{
    name: 'api backup p113',
    script: 'yarn',
    args: 'develop',
    instances : "2",
    exec_mode : "cluster"
  }],
};
