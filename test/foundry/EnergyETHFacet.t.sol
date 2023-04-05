// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/Address.sol';
import "forge-std/Test.sol";
import "forge-std/console.sol";
import '../../contracts/facets/ozOracleFacet.sol';
import '../../contracts/facets/EnergyETHFacet.sol';
import '../../contracts/testing-files/WtiFeed.sol';
import '../../contracts/testing-files/EthFeed.sol';
import '../../contracts/testing-files/GoldFeed.sol';
import '../../contracts/InitUpgradeV2.sol';
import '../../interfaces/ozIDiamond.sol';
import '../../libraries/PermitHash.sol';
import '../../interfaces/IPermit2.sol';


contract EnergyETHFacetTest is Test {

    bytes32 constant TOKEN_PERMISSIONS_TYPEHASH =
        keccak256("TokenPermissions(address token,uint256 amount)");
    bytes32 constant PERMIT_TRANSFER_FROM_TYPEHASH = keccak256(
        "PermitTransferFrom(TokenPermissions permitted,address spender,uint256 nonce,uint256 deadline)TokenPermissions(address token,uint256 amount)"
    );

    uint256 arbFork;
    uint ethFork;
    uint256 ownerKey;
    
    ozOracleFacet private ozOracle;
    EnergyETHFacet private energyFacet;
    InitUpgradeV2 private initUpgrade;
    WtiFeed private wtiFeed;
    EthFeed private ethFeed;
    GoldFeed private goldFeed;
    ozIDiamond private OZL;

    address private deployer = 0xe738696676571D9b74C81716E4aE797c2440d306;
    address private volIndex = 0xbcD8bEA7831f392bb019ef3a672CC15866004536;
    address private diamond = 0x7D1f13Dd05E6b0673DC3D0BFa14d40A74Cfa3EF2;

    address crvTricrypto = 0x8e0B8c8BB9db49a46697F3a5Bb8A308e744821D2;
    address yTricryptoPoolAddr = 0x239e14A19DFF93a17339DCC444f74406C17f8E67;
    address chainlinkAggregatorAddr = 0x639Fe6ab55C921f74e7fac1ee960C0B6293ba612;

    address ozLoupe = 0xd986Ac35f3aD549794DBc70F33084F746b58b534;
    address revenueFacet = 0xD552211891bdBe3eA006343eF80d5aB283De601C;

    IERC20 USDC = IERC20(0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8);

    IPermit2 permit2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    address bob;
    address alice = makeAddr('alice');
    address ray = makeAddr('ray');




    function setUp() public {
        arbFork = vm.createSelectFork(vm.rpcUrl('arbitrum'), 69254399); 

        (
            address[] memory facets,
            address[] memory feeds
        ) = _createContracts();

        initUpgrade = new InitUpgradeV2();

        OZL = ozIDiamond(diamond);

        bytes memory data = abi.encodeWithSelector(
            initUpgrade.init.selector,
            feeds,
            facets
        );

        //Creates FacetCut array
        ozIDiamond.FacetCut[] memory cuts = new ozIDiamond.FacetCut[](1);
        cuts[0] = _createCut(address(ozOracle), 0);

        vm.prank(deployer);
        OZL.diamondCut(cuts, address(initUpgrade), data);

        energyFacet = new EnergyETHFacet();

        //--------

        ownerKey = _randomUint256();
        bob = vm.addr(ownerKey);
        
        deal(address(USDC), bob, 5000 * 10 ** 6);

        targetSender(alice);
        targetSender(ray);
    }

  

    //---------

    function test_getPrice() public {
        uint price = energyFacet.getPrice();
        assertTrue(price > 0);
    }

   
    function invariant_myTest() public {
        assertTrue(true);
    }




    //------ Helpers -----


    function _createCut(
        address contractAddr_, 
        uint8 id_
    ) private view returns(ozIDiamond.FacetCut memory cut) {
        bytes4[] memory selectors = new bytes4[](1);
        if (id_ == 0) selectors[0] = ozOracle.getEnergyPrice.selector;

        cut = ozIDiamond.FacetCut({
            facetAddress: contractAddr_,
            action: ozIDiamond.FacetCutAction.Add,
            functionSelectors: selectors
        });
    }


    function _createContracts() private returns(
        address[] memory,
        address[] memory
    ) {
        ethFeed = new EthFeed();
        goldFeed = new GoldFeed();
        wtiFeed = new WtiFeed();

        ozOracle = new ozOracleFacet(); 
        energyFacet = new EnergyETHFacet();

        address[] memory facets = new address[](2);
        facets[0] = address(ozOracle);
        facets[1] = address(energyFacet);

        address[] memory feeds = new address[](4);
        feeds[0] = address(wtiFeed);
        feeds[1] = volIndex;
        feeds[2] = address(ethFeed);
        feeds[3] = address(goldFeed); 

        return (facets, feeds);
    }


    function _setLabels() private {
        vm.label(address(ozOracle), 'ozOracle');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(initUpgrade), 'initUpgrade');
        vm.label(address(wtiFeed), 'wtiFeed');
        vm.label(address(ethFeed), 'ethFeed');
        vm.label(address(goldFeed), 'goldFeed');
        vm.label(address(OZL), 'OZL');
        vm.label(deployer, 'deployer2');
        vm.label(volIndex, 'volIndex');
        vm.label(crvTricrypto, 'crvTricrypto');
        vm.label(yTricryptoPoolAddr, 'yTricryptoPool');
        vm.label(chainlinkAggregatorAddr, 'chainlinkAggregator');
        vm.label(ozLoupe, 'ozLoupe');
        vm.label(revenueFacet, 'revenueFacet');
        vm.label(address(energyFacet), 'energyFacet');
        vm.label(address(USDC), 'USDC');
        vm.label(address(permit2), 'permit2');
    }


    //---------
    function _randomBytes32() internal view returns (bytes32) {
        return keccak256(abi.encode(
            tx.origin,
            block.number,
            block.timestamp,
            block.coinbase,
            address(this).codehash,
            gasleft()
        ));
    }

    function _randomUint256() internal view returns (uint256) {
        return uint256(_randomBytes32());
    }

    //-----------

    // Generate a signature for a permit message.
    function _signPermit(
        IPermit2.PermitTransferFrom memory permit,
        address spender,
        uint256 signerKey
    ) internal view returns (bytes memory sig)
    {
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(signerKey, _getEIP712Hash(permit, spender));
        return abi.encodePacked(r, s, v);
    }

    // Compute the EIP712 hash of the permit object.
    // Normally this would be implemented off-chain.
    function _getEIP712Hash(IPermit2.PermitTransferFrom memory permit, address spender)
        internal
        view
        returns (bytes32 h)
    {
        return keccak256(abi.encodePacked(
            "\x19\x01",
            permit2.DOMAIN_SEPARATOR(),
            keccak256(abi.encode(
                PERMIT_TRANSFER_FROM_TYPEHASH,
                keccak256(abi.encode(
                    TOKEN_PERMISSIONS_TYPEHASH,
                    permit.permitted.token,
                    permit.permitted.amount
                )),
                spender,
                permit.nonce,
                permit.deadline
            ))
        ));
    }

}