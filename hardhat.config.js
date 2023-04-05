// require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-foundry");
require("@nomiclabs/hardhat-ethers");
require('dotenv').config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      // forking: {
      //   url: process.env.MAINNET,
      //   blockNumber: 16814476
      // },
      forking: {
        url: process.env.ARBITRUM,
        blockNumber: 69254391 //69254391
      }
    }
    // localhost: {
    //   url: process.env.GANACHE,
    //   accounts: [process.env.DEPLOYER2]
    // }
  }
};
