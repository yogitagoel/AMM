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

    uint256 public constant INITIAL_RESERVEB= 100 * 1e18;
    uint256 public constant INITIAL_RESERVEA = 100 * 1e18;
    uint256 public constant INITIAL_BALANCE=5e22;

    address public user = makeAddr("user");

    function setUp() external {

        deployer = new DeployAmm();
        (amm, tokenA, tokenB) = deployer.run();


        tokenA.mint(address(this),INITIAL_BALANCE);
        tokenB.mint(address(this),INITIAL_BALANCE);

        tokenA.mint(user,INITIAL_BALANCE);
        tokenB.mint(user,INITIAL_BALANCE);

        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);

        vm.startPrank(user);
        tokenA.approve(address(amm), type(uint256).max);
        tokenB.approve(address(amm), type(uint256).max);
        vm.stopPrank();

        amm.addLiquidity(INITIAL_RESERVEA, INITIAL_RESERVEB);
    }

    function testAddLiquidity(uint256 amountA, uint256 amountB) external {

        vm.assume(amountA > 0 && amountA <= 1e21);
        vm.assume(amountB > 0 && amountB <= 1e21);

        vm.prank(user);
        amm.addLiquidity(amountA, amountB);
        (uint256 reserveA , uint256 reserveB) = amm.getReserves();
        assert(reserveA==INITIAL_RESERVEA+amountA);
        assert(reserveB==INITIAL_RESERVEB+amountB);
    }

    function testRemoveLiquidity(uint256 liquidity) external {
 
        console.log(address(amm).balance);
        liquidity=bound(liquidity,0,address(amm).balance);

        console.log(liquidity);
        console.log(user.balance);

        vm.prank(user);
        uint256 Iinitial_Liquidity =amm.getLiquidity();
        amm.removeLiquidity(liquidity);
        assert(amm.getLiquidity()==Iinitial_Liquidity-liquidity);
    }

    function testSwapAtoB(uint256 amountA) external {
    vm.assume(amountA > 0 && amountA <= tokenA.balanceOf(user));

    uint256 reserveA = tokenA.balanceOf(address(amm));
    uint256 reserveB = tokenB.balanceOf(address(amm));
    uint256 initialBalanceB = tokenB.balanceOf(user);

    vm.prank(user);
    tokenA.approve(address(amm), amountA);

    vm.prank(user);
    amm.swapAtoB(amountA);

    uint256 fee = (amountA * amm.FEE_PERCENT()) / 1000;
    uint256 amountAfterFee = amountA - fee;
    uint256 expectedAmountB = (reserveB * amountAfterFee) / (reserveA + amountAfterFee);

    uint256 finalBalanceB = tokenB.balanceOf(user);
    assertEq(finalBalanceB, initialBalanceB + expectedAmountB, "Incorrect tokenB amount received by user");

    uint256 newReserveA = reserveA + amountAfterFee;
    uint256 newReserveB = reserveB - expectedAmountB;
    assertEq(tokenA.balanceOf(address(amm)), newReserveA, "Incorrect reserveA after swap");
    assertEq(tokenB.balanceOf(address(amm)), newReserveB, "Incorrect reserveB after swap");

    uint256 newProduct = newReserveA * newReserveB;
    uint256 oldProduct = reserveA * reserveB;
    assertApproxEqRel(newProduct, oldProduct, 1e16, "Constant product invariant broken");
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
        uint256 beforeK = INITIAL_RESERVEA * INITIAL_RESERVEB;
        uint256 afterK = reserveA * reserveB;
        assert(beforeK == afterK);
    }

    function testNonNegativeReserves() public {
        (uint256 reserveA, uint256 reserveB) = amm.getReserves();
        assert(reserveA >= 0);
        assert(reserveB >= 0);
    }
}
