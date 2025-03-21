// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {AMM} from "../src/AMM.sol";
import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {DeployAmm} from "../script/AmmDeploy.s.sol";
import {ERC20Mock} from "../lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract AmmTest is Test {
    DeployAmm deployer;
    AMM public amm;

    ERC20Mock public tokenA;
    ERC20Mock public tokenB;

    uint initial_reserveA = 100 * 1e18;
    uint initial_reserveB = 100 * 1e18;

    address public user = makeAddr("user");

    function setUp() external {

        deployer = new DeployAmm();
        (amm, tokenA, tokenB) = deployer.run();


        tokenA.mint(address(this),1000 ether);
        tokenB.mint(address(this),1000 ether);

        tokenA.mint(user,1000 ether);
        tokenB.mint(user,1000 ether);

        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);

        vm.startPrank(user);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        amm.addLiquidity(initial_reserveA, initial_reserveB);
    }

    function testAddLiquidity(uint256 amountA, uint256 amountB) external {
        vm.assume(amountA > 0);
        vm.assume(amountB > 0);
        vm.prank(user);
        amm.addLiquidity(amountA, amountB);
        (uint256 reserveA , uint256 reserveB) = amm.getReserves();
        assert(reserveA==initial_reserveA+amountA);
        assert(reserveB==initial_reserveB+amountB);
    }

    function testRemoveLiquidity(uint256 liquidity) external {
        vm.prank(user);
        amm.removeLiquidity(liquidity);
    }

    function testSwapAtoB(uint256 amountA) external {
        vm.assume(amountA > 0);
        vm.prank(user);
        tokenA.approve(address(amm), amountA);
        amm.swapAtoB(amountA);
    }

    function testSwapBtoA(uint256 amountB) external {
        vm.assume(amountB > 0);
        vm.prank(user);
        tokenB.approve(address(amm), amountB);
        amm.swapBtoA(amountB);
    }

    function testGetReserve() external {
        vm.prank(user);
        amm.getReserves();
    }

    function testGetBalance(address token) external {
        vm.prank(user);
        amm.getBalance(token);
    }

    function testGetLiquidity() external {
        vm.prank(user);
        amm.getLiquidity();
    }

    function testConstantProduct() public {
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        uint256 beforeK = initial_reserveA * initial_reserveB;
        uint256 afterK = reserveA * reserveB;
        assert(beforeK == afterK);
    }

    function testNonNegativeReserves() public {
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        assert(reserveA >= 0);
        assert(reserveB >= 0);
    }
}
