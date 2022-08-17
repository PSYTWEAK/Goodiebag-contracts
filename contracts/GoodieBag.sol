// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import { IWETH9 } from "./IWETH9.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract GoodieBag {
  address public weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

  event MultiBuy(address account, uint256 value);

  /*  
    ================================================================
                        Public Functions
    ================================================================ 
    */

  function multiBuy(
    address router,
    address[] memory tokens,
    bytes[] memory swapCalldatas
  ) external payable approve(router) refundETH {
    depositETH();
    for (uint256 i = 0; i < swapCalldatas.length; i++) {
      swap(router, tokens[i], swapCalldatas[i]);
    }
    emit MultiBuy(msg.sender, msg.value);
  }

  /*  
    ================================================================
                        Interal Functions
    ================================================================ 
    */

  function depositETH() internal {
    IWETH9(payable(weth)).deposit{ value: msg.value }();
  }

  function swap(
    address router,
    address token,
    bytes memory swapCalldata
  ) internal transferTokens(token) returns (bytes memory) {
    (bool success, bytes memory returndata) = router.call(swapCalldata);
    if (!success) {
      if (returndata.length == 0) revert();
      assembly {
        revert(add(32, returndata), mload(returndata))
      }
    }
    return returndata;
  }

  /*  
    ================================================================
                            Modifers 
    ================================================================ 
    */

  modifier approve(address router) {
    uint256 MAX_INT = 2**256 - 1;
    IWETH9(payable(weth)).approve(router, MAX_INT);
    _;
  }
  modifier refundETH() {
    IWETH9 wrappedETH = IWETH9(payable(weth));
    uint256 balanceBefore = wrappedETH.balanceOf(address(this));
    _;
    uint256 balanceAfter = wrappedETH.balanceOf(address(this));
    if (balanceBefore < balanceAfter) {
      uint256 refund = balanceAfter - balanceBefore;
      wrappedETH.withdraw(refund);
      payable(msg.sender).transfer(refund);
    }
  }

  modifier transferTokens(address token) {
    uint256 balanceBefore = IERC20(token).balanceOf(address(this));
    _;
    uint256 balanceAfter = IERC20(token).balanceOf(address(this));
    if (balanceBefore < balanceAfter) {
      uint256 amount = balanceAfter - balanceBefore;
      IERC20(token).transfer(msg.sender, amount);
    }
  }
}
