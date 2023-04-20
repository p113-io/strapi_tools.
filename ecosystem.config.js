module.exports = {
  apps : [{
    name: 'api.mydomain',
    script: 'yarn',
    interpreter: "bash",
    args: 'develop',
    instances : "2",
    exec_mode : "cluster"
  }],
};
