// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract AMM is ReentrancyGuard{
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public totalSupply;

    mapping(address => uint) public balance;

    uint256 public constant FEE_PERCENT = 3;

    constructor(address _tokenA, address _tokenB) {
        require(
            _tokenA != address(0) && _tokenB != address(0),
            "Invalid token address"
        );
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    function addLiquidity(
        uint256 _amountA,
        uint256 _amountB
    ) external {
        require(_amountA > 0 && _amountB > 0, "Insufficient amount");

        require(
            tokenA.transferFrom(msg.sender, address(this), _amountA),
            "Transfer failed"
        );
        require(
            tokenB.transferFrom(msg.sender, address(this), _amountB),
            "Transfer failed"
        );

        uint256 liquidityMinted;
        if (totalSupply == 0) {
            liquidityMinted = sqrt(_amountA * _amountB);
        } else {
            liquidityMinted = min(
                (_amountA * totalSupply) / reserveA,
                (_amountB * totalSupply) / reserveB
            );
        }

        balance[msg.sender] += liquidityMinted;
        totalSupply += liquidityMinted;
        reserveA += _amountA;
        reserveB += _amountB;
    }

    function removeLiquidity(uint256 _liquidity) external {
        require(
            _liquidity >= 0 && balance[msg.sender] >= _liquidity,
            "Insufficient liquidity"
        );

        uint256 amountA = (_liquidity * reserveA) / totalSupply;
        uint256 amountB = (_liquidity * reserveB) / totalSupply;

        require(tokenA.transfer(msg.sender, amountA), "Transfer failed");
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed");

        balance[msg.sender] -= _liquidity;
        totalSupply -= _liquidity;
        reserveA -= amountA;
        reserveB -= amountB;
    }

    function swapAtoB(uint256 _amountA) external returns (uint256 amountB){
        require(_amountA > 0, "Amount must be greater than zero");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        uint256 fee = (_amountA * FEE_PERCENT) / 1000;
        uint256 amountAfterFee = _amountA - fee;
        amountB = (reserveB * amountAfterFee) /
            (reserveA + amountAfterFee);

        require(
            tokenA.transferFrom(msg.sender, address(this), _amountA),
            "Transfer failed"
        );
        require(tokenB.transfer(msg.sender, amountB), "Transfer failed");

        reserveA += amountAfterFee;
        reserveB -= amountB;

        return amountB;

    }

    function swapBtoA(uint256 _amountB) external nonReentrant {
        require(_amountB > 0, "Amount must be greater than zero");
        require(reserveA > 0 && reserveB > 0, "Insufficient liquidity");

        uint256 fee = (_amountB * FEE_PERCENT) / 1000;
        uint256 amountAfterFee = _amountB - fee;
        uint256 amountA = (reserveA * amountAfterFee) /
            (reserveB + amountAfterFee);

        require(amountA > 0 && amountA < reserveA, "Invalid output amount");

        require(
            tokenB.transferFrom(msg.sender, address(this), _amountB),
            "Transfer failed"
        );
        require(tokenA.transfer(msg.sender, amountA), "Transfer failed");

        reserveA -= amountA;
        reserveB += amountAfterFee;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x < y ? x : y;
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserveA, reserveB);
    }

    function getLiquidity() external view returns (uint256) {
        return totalSupply;
    }

    function getBalance(address _account) external view returns (uint256) {
        return balance[_account];
    }
}
