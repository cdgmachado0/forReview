const hre = require("hardhat");
const { Bridge } = require('arb-ts');
const { hexDataLength } = require('@ethersproject/bytes');
require('dotenv').config();

const signer = new ethers.Wallet(process.env.PK);
const l2Provider = new ethers.providers.JsonRpcProvider(process.env.ARB_TESTNET);
const l1ProviderRinkeby = new ethers.providers.JsonRpcProvider(process.env.RINKEBY);
const l2Signer = signer.connect(l2Provider);
const l1Signer = signer.connect(l1ProviderRinkeby);

async function main() {
  const bridge = await Bridge.init(l1Signer, l2Signer);
  const nodeAddr = '0x00000000000000000000000000000000000000C8';
  const value = ethers.utils.parseEther('0.01');
  const value2 = ethers.utils.parseEther('0.015');
  const signerAddr = await signer.getAddress();
  const nodeInterface = await hre.ethers.getContractAt('NodeInterface', nodeAddr);
  const usdtAddrArb = '0x3B00Ef435fA4FcFF5C209a37d1f3dcff37c705aD';



  const sendToArbBytes = ethers.utils.defaultAbiCoder.encode(
    ['address', 'address'],
    [signerAddr, usdtAddrArb]
  );
  const sendToArbBytesLength = hexDataLength(sendToArbBytes) + 4;

  const [_submissionPriceWei] =
  await bridge.l2Bridge.getTxnSubmissionPrice(sendToArbBytesLength);

  const submissionPriceWei = _submissionPriceWei.mul(5);
  const maxSubmissionCost = submissionPriceWei;
  const gasPriceBid = await bridge.l2Provider.getGasPrice();

  const iface = new ethers.utils.Interface([
    'function exchangeToUserToken(address _user, address _userToken)'
  ]);
  const data = iface.encodeFunctionData('exchangeToUserToken', [signerAddr, usdtAddrArb]);

  const y = await nodeInterface.estimateRetryableTicket(
      signerAddr,
      value2,
      '0x9be7F57F8524B5c26E564007F14E614e7A0a34ab',
      value,
      maxSubmissionCost,
      '0x9be7F57F8524B5c26E564007F14E614e7A0a34ab',
      '0x9be7F57F8524B5c26E564007F14E614e7A0a34ab',
      3000000,
      gasPriceBid,
      data
  );

  console.log('y: ', (y[0]).toString());

}





// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
