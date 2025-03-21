// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "../lib/forge-std/src/Script.sol";
import {AMM} from "../src/AMM.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract DeployAmm is Script {
    AMM public amm;
    function run() external returns (AMM deployedAmm, ERC20Mock tokenA, ERC20Mock tokenB) {
        vm.startBroadcast();
        tokenA = new ERC20Mock();
        tokenB = new ERC20Mock();
        amm = new AMM(address(tokenA), address(tokenB));
        vm.stopBroadcast();
        return (amm, tokenA, tokenB);
    }
}
