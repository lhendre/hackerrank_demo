var Dao = artifacts.require("./Dao.sol");

module.exports = function(deployer) {
  //deployer is the truffel api that handles deployment.  First parameter is the contract followed by constructor arguments
  //Pass arguments in the form of a string
  deployer.deploy(Dao,["0x74657374737472696e6700000000000000000000000000000000000000000000"]);

};
