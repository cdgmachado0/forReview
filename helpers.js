const { ethers } = require('ethers');
const { 
    formatUnits, 
    parseEther, 
    formatEther 
} = ethers.utils;
const { 
    mine, 
    impersonateAccount,
    stopImpersonatingAccount
 } = require("@nomicfoundation/hardhat-network-helpers");

const { 
    diamondABI, 
    ozDiamondAddr,
    deployer2,
    opsL2_2
} = require('./state-vars');


async function deployContract(contractName, constrArgs) {
    let var1, var2, var3, var4;
    let contract;

    const Contract = await hre.ethers.getContractFactory(contractName);

    switch(contractName) {
        case null:
            ([ var1, var2, var3, var4 ] = constrArgs);
            contract = await Contract.deploy(var1, var2, var3, var4);
            break;
        default:
            contract = await Contract.deploy();
    }

    await contract.deployed();
    console.log(`${contractName} deployed to: `, contract.address);

    return contract;
}


async function sendETHOps(amount, receiver) {
    const [signer] = await hre.ethers.getSigners();
    let balance = await signer.getBalance();
    // console.log('addr: ', await signer.getAddress());
    
    tx = await signer.sendTransaction({
        value: parseEther(amount.toString()),
        to: receiver,
        gasLimit: ethers.BigNumber.from('5000000'),
        gasPrice: ethers.BigNumber.from('5134698068')
    });
    await tx.wait();

    balance = await signer.getBalance();
}



async function getLastPrice(blockDifference_, num_) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);
    let price = await ozDiamond.getLastPrice();
    console.log(`eETH price ${num_}: `, formatUnits(price, 18));
    if (blockDifference_ !== '') await mine(blockDifference_);
}



async function addToDiamond(ozOracle, feeds) {
    const ozDiamond = await hre.ethers.getContractAt(diamondABI, ozDiamondAddr);

    const lastPriceSelector = ozOracle.interface.getSighash('getEnergyPrice');
    const facetCutArgs = [
        [ozOracle.address, 0, [lastPriceSelector] ]
    ];
    const facetAddresses = [
        ozOracle.address,
    ];

    const init = await deployContract('InitUpgradeV2');
    const initData = init.interface.encodeFunctionData('init', [
        feeds,
        facetAddresses
    ]);

    await sendETHOps(1, deployer2);

    await impersonateAccount(deployer2);
    const deployerSigner = await hre.ethers.provider.getSigner(deployer2);

    // const dataA = ozDiamond.interface.encodeFunctionData('diamondCut', [
    //     facetCutArgs, init.address, initData
    // ]);
    // console.log('data: ', dataA);

    const tx = await ozDiamond.connect(deployerSigner).diamondCut(facetCutArgs, init.address, initData);
    const receipt = await tx.wait();
    console.log('ozOracle added to ozDiamond: ', receipt.transactionHash);

    await stopImpersonatingAccount(deployer2);
}





module.exports = {
    deployContract,
    getLastPrice,
    addToDiamond,
    sendETHOps
};