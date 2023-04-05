// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import '../../interfaces/ozIDiamond.sol';
import '../../interfaces/IPermit2.sol';
// import './ozOracleFacet.sol';
import "forge-std/console.sol";
// import 'hardhat/console.sol';


error Cant_be_zero();
error Not_enough_funds(uint256 buyerBalance);
error Cant_approve(uint256 amount);
error Cant_transfer(uint256 amount);


contract EnergyETHFacet is ERC20 {

    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);
    address immutable wethAdrr = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    ozIDiamond OZL = ozIDiamond(0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2);
    IPermit2 immutable PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    constructor() ERC20('Energy ETH', 'eETH') {}


    function getPrice() public view returns(uint256) {
        return OZL.getEnergyPrice();
    }


    function _issue(
        IERC20 token,
        // uint256 amount,
        // uint256 nonce,
        // uint256 deadline,
        // bytes calldata signature,
        IPermit2.Permit2Buy memory buyOp_
    ) private {
        uint256 amount = buyOp_.amount;

        console.log('----- facet ----');
        console.log('amount: ', amount);
        console.log('token: ', address(token));
        console.log('nonce: ', buyOp_.nonce);
        console.log('deadline: ', buyOp_.deadline);
        console.log('address(this): ', address(this));
        console.log('buyer: ', buyOp_.buyer);
        console.log('sender = buyer: ', msg.sender);
        console.logBytes(buyOp_.signature);
        console.log('signature ^^^^');
        console.log('allowance - sender: ', token.allowance(msg.sender, address(PERMIT2)));
        console.log('token bal - sender: ', token.balanceOf(msg.sender));
        console.log('allowance - buyer: ', token.allowance(buyOp_.buyer, address(PERMIT2)));
        console.log('token bal - buyer: ', token.balanceOf(buyOp_.buyer));
        console.log('----- facet ----');

        PERMIT2.permitTransferFrom(
            IPermit2.PermitTransferFrom({
                permitted: IPermit2.TokenPermissions({
                    token: token,
                    amount: amount
                }),
                nonce: buyOp_.nonce,
                deadline: buyOp_.deadline
            }),
            IPermit2.SignatureTransferDetails({
                to: address(this),
                requestedAmount: amount
            }),
            msg.sender,
            buyOp_.signature
        );


    }

    // struct Permit2Buy {
    //     address buyer; //user_
    //     uint256 amount; //eETH to buy
    //     uint256 nonce;
    //     uint256 deadline;
    //     bytes signature;
    // }


    
    function issue(IPermit2.Permit2Buy memory buyOp_) external {
        uint256 toBuy = buyOp_.amount;

        if (toBuy == 0) revert Cant_be_zero();

        uint256 quote = (toBuy * getPrice()) / 10 ** 12;
        uint256 buyerBalance = USDC.balanceOf(msg.sender);

        if (buyerBalance < quote) revert Not_enough_funds(buyerBalance);

        buyOp_.amount = quote;

        _issue(USDC, buyOp_);

        //---------
        // bool success = USDC.transferFrom(msg.sender, address(this), quote);
        // if (!success) revert Cant_transfer(quote);
        //--------

        // ISwapRouter.ExactInputSingleParams memory params =
        //     ISwapRouter.ExactInputSingleParams({
        //         tokenIn: address(USDC),
        //         tokenOut: wethAdrr, 
        //         fee: eMode.poolFee,
        //         recipient: address(this),
        //         deadline: block.timestamp,
        //         amountIn: USDC.balanceOf(address(this)),
        //         amountOutMinimum: _calculateMinOut(eMode, i, balanceWETH, slippage_), 
        //         sqrtPriceLimitX96: 0
        //     });
        

    }


    function _depositInDeFi() private {



    }


}

