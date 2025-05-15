// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SingleBuy {
    address public constant WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    /**
     * @notice Executes a token swap via a given router, ensuring tokens are received by `to`.
     * @param router The swap router to call.
     * @param token The ERC20 token expected to be received.
     * @param swapCalldata Encoded function call for the swap.
     * @param to The final recipient of the swapped tokens.
     */
    function swap(
        address router,
        address token,
        bytes calldata swapCalldata,
        address to
    )
        external
        approveRouter(router)
        transferTokens(token, to)
        onlyThis
        returns (bytes memory result)
    {
        (bool success, bytes memory returndata) = router.call(swapCalldata);

        if (!success) {
            if (returndata.length == 0) revert("Swapper: Call failed");
            assembly {
                revert(add(returndata, 32), mload(returndata))
            }
        }

        return returndata;
    }

    /**
     * @dev Ensures any tokens sent to the contract during swap are forwarded to the user.
     */
    modifier transferTokens(address token, address to) {
        IERC20 t = IERC20(token);

        uint256 toBalanceBefore = t.balanceOf(to);
        uint256 contractBalanceBefore = t.balanceOf(address(this));

        _;

        uint256 toBalanceAfter = t.balanceOf(to);
        uint256 contractBalanceAfter = t.balanceOf(address(this));

        require(
            toBalanceAfter > toBalanceBefore || contractBalanceAfter > contractBalanceBefore,
            "Swapper: No tokens received"
        );

        if (contractBalanceAfter > contractBalanceBefore) {
            uint256 amountReceived = contractBalanceAfter - contractBalanceBefore;
            t.transfer(to, amountReceived);
        }
    }

    /**
     * @dev Approves the router to spend WETH before the call, and revokes afterward.
     */
    modifier approveRouter(address router) {
        IERC20 wethToken = IERC20(WETH);
        wethToken.approve(router, type(uint256).max);
        _;
        wethToken.approve(router, 0);
    }

    /**
     * @dev Restricts function to only be callable internally via `this.swap(...)`.
     */
    modifier onlyThis() {
        require(msg.sender == address(this), "Swapper: Only callable internally");
        _;
    }
}
