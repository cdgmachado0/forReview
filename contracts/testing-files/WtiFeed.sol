// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

// import 'hardhat/console.sol';
import "forge-std/console.sol";

contract WtiFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        // console.log('blockNum: ', blockNum);

        assembly {
            switch blockNum 
            case 69254399 { result := 7632500000 } 
            case 69254400 { result := 7632500000 } 
            case 69254401 { result := 7632500000 } 
            case 69255699 { result := 7672000000 } 
            case 69260699 { result := 7717200000 } 
            case 69294699 { result := 7677600000 } 
            case 69295699 { result := 7704200000 } 
            case 69297699 { result := 7639200000 } 
            case 69380699 { result := 7674920000 } 
            case 69421699 { result := 7592500000 } 
        }

        return (1,result,0,0,0);
    }

    function getRoundData(uint80 roundId_) external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result = int(uint(roundId_) - uint(roundId_));

        assembly {
            switch blockNum 
            case 69254399 { result := 7672000000 }
            case 69254400 { result := 7632500000 } 
            case 69254401 { result := 7672000000 }
            case 69255699 { result := 7717200000 }
            case 69260699 { result := 7677600000 }
            case 69294699 { result := 7704200000 }
            case 69295699 { result := 7639200000 }
            case 69297699 { result := 7674920000 }
            case 69380699 { result := 7592500000 }
            case 69421699 { result := 7632500000 }
        }

        return (0,result,0,0,0);
    }
}