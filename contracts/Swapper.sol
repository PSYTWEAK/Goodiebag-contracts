// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Swapper {
    address public weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address public goodieBag;

    constructor(address _goodieBag) {
        goodieBag = _goodieBag;
    }

    function swap(
        address router,
        address token,
        bytes memory swapCalldata,
        address to
    )
        public
        onlyGoodieBag
        approveRouter(router)
        transferTokens(token, to)
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = router.call(swapCalldata);
        if (!success) {
            if (returndata.length == 0) revert();
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
        return returndata;
    }

    function approveGoodiebag() public onlyGoodieBag {
        uint256 MAX_INT = 2**256 - 1;
        IERC20(payable(weth)).approve(goodieBag, MAX_INT);
    }

    modifier transferTokens(address token, address to) {
        uint256 balanceBefore = IERC20(token).balanceOf(address(this));
        _;
        uint256 balanceAfter = IERC20(token).balanceOf(address(this));
        if (balanceBefore < balanceAfter) {
            uint256 amount = balanceAfter - balanceBefore;
            IERC20(token).transfer(to, amount);
            require(
                IERC20(token).balanceOf(address(this)) == balanceBefore,
                "Swapper: transferTokens failed"
            );
        }
    }

    modifier approveRouter(address router) {
        uint256 MAX_INT = 2**256 - 1;
        IERC20(weth).approve(router, MAX_INT);
        _;
        IERC20(weth).approve(router, 0);
    }

    modifier onlyGoodieBag() {
        require(msg.sender == goodieBag, "Swapper: Only GoodieBag can call");
        _;
    }
}
