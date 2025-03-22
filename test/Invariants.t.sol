// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {AMM} from "../src/AMM.sol";
import {DeployAmm} from "../script/AmmDeploy.s.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantTest is Test{
    AMM public amm;
    Handler public handler;
    ERC20Mock public tokenA;
    ERC20Mock public tokenB;
    

    function setUp() external {
        
        (amm,tokenA,tokenB)=new DeployAmm().run();
        handler = new Handler(amm);

        tokenA.mint(address(this),1e20);
        tokenB.mint(address(this),1e20);

        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        amm.addLiquidity(1e18,1e18);
    }

    function testConstantProduct() public view{
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        uint256 afterK = reserveA * reserveB;

        uint256 beforeK = handler.Initial_product();
        assert(beforeK <= afterK);
    }

    function testNonNegativeReserves() public view {
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        assert(reserveA >= 0);
        assert(reserveB >= 0);
    }
}