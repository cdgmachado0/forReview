// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import '../AppStorage.sol';
import "forge-std/console.sol";

// import 'hardhat/console.sol';

//add modularity to add and remove chainlink feeds
//add uniswap and trellors oracles as a fallback
contract ozOracleFacet {

    AppStorage s;

    int256 private constant EIGHT_DEC = 1e8;
    int256 private constant NINETN_DEC = 1e19;

    int constant BASE = 1e7;



    //**** MAIN ******/

    function getEnergyPrice() external view returns(uint256) {
        (Data memory data, int basePrice) = _getDataFeeds();
        int256 volIndex = data.volIndex.value;

        int256 implWti = _setPrice(data.wtiPrice, volIndex, s.wtiFeed); 
        int256 implGold = _setPrice(data.goldPrice, volIndex, s.goldFeed);
        int256 implEth = _setPrice(data.ethPrice, 0, s.ethFeed);

        int256 netDiff = implWti + implEth + implGold;

        return uint256(basePrice + ( (netDiff * basePrice) / (100 * EIGHT_DEC) ));
    }

    //------------------


    function _getDataFeeds() private view returns(Data memory data, int basePrice) {
        (,int256 volatility,,,) = s.volatilityFeed.latestRoundData();
        (uint80 wtiId, int256 wtiPrice,,,) = s.wtiFeed.latestRoundData();
        (uint80 ethId, int256 ethPrice,,,) = s.ethFeed.latestRoundData();
        (uint80 goldId, int256 goldPrice,,,) = s.goldFeed.latestRoundData();

        basePrice = _calculateBasePrice(ethPrice);

        data = Data({
            volIndex: DataInfo({
                roundId: 0,
                value: volatility
            }),
            wtiPrice: DataInfo({
                roundId: wtiId,
                value: wtiPrice
            }),
            ethPrice: DataInfo({
                roundId: ethId,
                value: ethPrice
            }),
            goldPrice: DataInfo({
                roundId: goldId,
                value: goldPrice
            })
        });
    }


     function _getPrevFeed(
        uint80 roundId_, 
        AggregatorV3Interface feed_
    ) private view returns(int256) {
        (,int256 prevPrice,,,) = feed_.getRoundData(roundId_ - 1);
        return prevPrice;
    }

    function _setPrice(
        DataInfo memory price_, 
        int256 volIndex_, 
        AggregatorV3Interface feed_
    ) private view returns(int256) {
        if (address(feed_) != address(s.ethFeed)) {
            int256 currPrice = price_.value;
            int256 netDiff = currPrice - _getPrevFeed(price_.roundId, feed_);
            return ( (netDiff * 100 * EIGHT_DEC) / currPrice ) * (volIndex_ / NINETN_DEC);
        } else {
            int256 prevEthPrice = _getPrevFeed(price_.roundId, feed_);
            int256 netDiff = price_.value - prevEthPrice;
            return (netDiff * 100 * EIGHT_DEC) / prevEthPrice;
        }
    }

    function _calculateBasePrice(int256 ethPrice_) private pure returns(int256) {
        return ( (100 * EIGHT_DEC * ethPrice_) / 10 * EIGHT_DEC ) / BASE;
    }
    

}




