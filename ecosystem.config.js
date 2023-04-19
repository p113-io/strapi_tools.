module.exports = {
  apps : [{
    name: 'api backup p113',
    script: 'yarn',
    interpreter: "bash",
    args: 'develop',
    instances : "2",
    exec_mode : "cluster"
  }],
};
