// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Test, console} from "forge-std/Test.sol";
import {AMM} from "../src/AMM.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {DeployAmm} from "../script/AmmDeploy.s.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract AmmTest is Test {
    DeployAmm deployer;
    AMM public amm;

    ERC20Mock public tokenA;
    ERC20Mock public tokenB;

    uint initial_reserveA = 1000 * 1e18;
    uint initial_reserveB = 1000 * 1e18;

    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    function setUp() external {
        deployer = new DeployAmm();
        (amm, tokenA, tokenB) = deployer.run();

        tokenA.transfer(user1, 1e20);
        tokenB.transfer(user1, 1e20);
        tokenA.approve(user1, 1e20);
        tokenB.approve(user1, 1e20);

        amm.initialLiquidity(initial_reserveA, initial_reserveB);
    }

<<<<<<< HEAD
    function testFuzz_AddLiquidity(uint256 amountA, uint256 amountB) external {
=======
    function testAddLiquidity(uint256 amountA, uint256 amountB) external {
>>>>>>> fd97e2f (a)
        vm.assume(amountA > 0);
        vm.assume(amountB > 0);
        vm.prank(user1);
        tokenA.approve(address(amm), 1e20);
        tokenB.approve(address(amm), 1e20);
        vm.prank(user1);
        amm.addLiquidity(amountA, amountB);
    }

<<<<<<< HEAD
    function testFuzz_RemoveLiquidity(uint256 liquidity) external {
=======
    function testRemoveLiquidity(uint256 liquidity) external {
>>>>>>> fd97e2f (a)
        vm.prank(user1);
        amm.removeLiquidity(liquidity);
    }

<<<<<<< HEAD
    function testFuzz_SwapAtoB(uint256 amountA) external {
=======
    function testFSwapAtoB(uint256 amountA) external {
>>>>>>> fd97e2f (a)
        vm.assume(amountA > 0);
        vm.prank(user1);
        tokenA.approve(address(amm), amountA);
        amm.swapAtoB(amountA);
    }

<<<<<<< HEAD
    function testFuzz_SwapBtoA(uint256 amountB) external {
=======
    function testSwapBtoA(uint256 amountB) external {
>>>>>>> fd97e2f (a)
        vm.assume(amountB > 0);
        vm.prank(user1);
        tokenB.approve(address(amm), amountB);
        amm.swapBtoA(amountB);
    }

<<<<<<< HEAD
    function testFuzz_GetReserve() external {
=======
    function testGetReserve() external {
>>>>>>> fd97e2f (a)
        vm.prank(user1);
        amm.getReserves();
    }

<<<<<<< HEAD
    function testFuzz_GetBalance(address token) external {
=======
    function testGetBalance(address token) external {
>>>>>>> fd97e2f (a)
        vm.prank(user1);
        amm.getBalance(token);
    }

<<<<<<< HEAD
    function testFuzz_GetLiquidity() external {
=======
    function testGetLiquidity() external {
>>>>>>> fd97e2f (a)
        vm.prank(user1);
        amm.getLiquidity();
    }

<<<<<<< HEAD
    function testInvariant_ConstantProduct() public {
=======
    function testIConstantProduct() public {
>>>>>>> fd97e2f (a)
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        uint256 beforeK = initial_reserveA * initial_reserveB;
        uint256 afterK = reserveA * reserveB;
        assert(beforeK == afterK);
    }

<<<<<<< HEAD
    function testInvariant_NonNegativeReserves() public {
=======
    function testNonNegativeReserves() public {
>>>>>>> fd97e2f (a)
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        assert(reserveA >= 0);
        assert(reserveB >= 0);
    }
<<<<<<< HEAD
}
=======
}
>>>>>>> fd97e2f (a)
