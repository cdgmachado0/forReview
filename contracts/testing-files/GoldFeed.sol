// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;


contract GoldFeed {

    function latestRoundData() external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result;

        assembly {
            switch blockNum
            case 69254399 { result := 188117000000 } 
            case 69254400 { result := 188117000000 } 
            case 69254401 { result := 188117000000 } 
            case 69255699 { result := 189157000000 } 
            case 69260699 { result := 189157000000 } 
            case 69294699 { result := 188161500000 } 
            case 69295699 { result := 188161500000 } 
            case 69297699 { result := 188161500000 } 
            case 69380699 { result := 187211000000 } 
            case 69421699 { result := 188220158450 } 
        }

        return (1,result,0,0,0);
    }

    function getRoundData(uint80 roundId_) external view returns(int, int, int, int, int) {
        uint blockNum = block.number;
        int result = int(uint(roundId_) - uint(roundId_));

        assembly {
            switch blockNum 
            case 69254399 { result := 188917000000 }
            case 69254400 { result := 188917000000 }
            case 69254401 { result := 188917000000 }
            case 69255699 { result := 190157000000 }
            case 69260699 { result := 186757000000 }
            case 69294699 { result := 187261500000 }
            case 69295699 { result := 191261500000 }
            case 69297699 { result := 187161500000 }
            case 69380699 { result := 186011000000 }
            case 69421699 { result := 185720158450 }
        }

        return (0,result,0,0,0);
    }
}