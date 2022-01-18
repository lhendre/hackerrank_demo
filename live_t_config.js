const path = require("path");


module.exports = {
  networks: {
    "live": {
      network_id: 1,
      host: "127.0.0.1",
      port: 8546   // Different than the default below
    }
  },
  rpc: {
    host: "127.0.0.1",
    port: 8545
  },
  solc: {
    version: "^0.7.0"
  }
};
