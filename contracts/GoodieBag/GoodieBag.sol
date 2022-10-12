// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {IWETH9} from "../interfaces/IWETH9.sol";
import {Swapper} from "./Swapper.sol";
import {VaultHandler} from "./VaultHandler.sol";

contract GoodieBag is
    Swapper,
    VaultHandler(0x0000000000000000000000000000000000000066)
{
    event MultiBuy(address account, uint256 value);

    /*  
    ================================================================
                        Public Functions
    ================================================================ 
    */

    function multiBuy(
        address[] memory router,
        address[] memory tokens,
        bytes[] memory swapCalldatas,
        bool usingVault
    ) external payable {
        depositETH();
        address to = usingVault ? useVault(msg.sender) : msg.sender;
        for (uint256 i = 0; i < swapCalldatas.length; i++) {
            _swap(router[i], tokens[i], swapCalldatas[i], to);
        }
        refundETH(msg.sender);
        emit MultiBuy(msg.sender, msg.value);
    }

    /*  
    ================================================================
                        Internal Functions
    ================================================================ 
    */

    function depositETH() internal {
        IWETH9(payable(weth)).deposit{value: msg.value}();
    }

    function _swap(
        address router,
        address token,
        bytes memory swapCalldata,
        address to
    ) internal {
        try this.swap(router, token, swapCalldata, to) returns (
            bytes memory
        ) {} catch {}
    }

    function refundETH(address to) internal {
        uint256 balance = IWETH9(payable(weth)).balanceOf(address(this));
        if (balance > 0) {
            IWETH9(payable(weth)).withdrawTo(to, balance);
        }
    }
}
