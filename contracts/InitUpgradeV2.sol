// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import './AppStorage.sol';
import '../libraries/LibDiamond.sol';
// import 'hardhat/console.sol';

contract InitUpgradeV2 {

    AppStorage s;

    function init(
        address[] calldata feeds_,
        address[] memory facets_
    ) external {

        s.wtiFeed = AggregatorV3Interface(feeds_[0]);
        s.volatilityFeed = AggregatorV3Interface(feeds_[1]);
        s.ethFeed = AggregatorV3Interface(feeds_[2]);
        s.goldFeed = AggregatorV3Interface(feeds_[3]);

        // address[] memory facets = new address[](2);
        // facets[0] = facets_[0];
        // facets[0] = facets_[1];

        LibDiamond.setNonRevenueFacets(facets_); //test if anyone cann call setNonRevenueFacets

        //--------
    

    }
}