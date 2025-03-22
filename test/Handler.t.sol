// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {AMM} from "../src/AMM.sol";
import {DeployAmm} from "../script/AmmDeploy.s.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Handler is Test {
    AMM amm;
    ERC20Mock tokenA;
    ERC20Mock tokenB;
    uint256 public Initial_product;

    constructor(AMM _amm){
        amm=_amm;
        (uint256 reserveA,uint256 reserveB)=amm.getReserves();
        Initial_product=reserveA*reserveB;
    }

    function addLiquidity(uint256 amountA,uint256 amountB) public{
        amm.addLiquidity(amountA,amountB);
    }

    function removeLiquidity(uint256 liquidity) public{
        amm.removeLiquidity(liquidity);
    }

    function swapAtoB(uint256 amountA) public{
        amm.swapAtoB(amountA);
    }

    function swapBtoA(uint256 amountB) public{
        amm.swapBtoA(amountB);
    }
}