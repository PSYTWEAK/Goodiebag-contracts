// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {IWETH9} from "../interfaces/IWETH9.sol";
import {Swapper} from "./Swapper.sol";
import {VaultHandler} from "./VaultHandler.sol";

contract GoodieBag is VaultHandler, Swapper {
    event MultiBuy(address account, uint256 value);

    /*  
    ================================================================
                        Public Functions
    ================================================================ 
    */

    function multiBuy(
        uint64[] memory router,
        uint64[] memory tokens,
        bytes[] memory swapCalldatas,
        bool usingVault
    ) external payable setUsingVault(usingVault) {
        depositETH();
        for (uint256 i = 0; i < swapCalldatas.length; i++) {
            _swap(router[i], tokens[i], swapCalldatas[i]);
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
        uint256 router,
        uint256 token,
        bytes memory swapCalldata
    ) internal {
        try
            this.swap(
                router,
                token,
                swapCalldata,
                getReceiverAddress(msg.sender)
            )
        returns (bytes memory) {} catch {}
    }

    function refundETH(address to) internal {
        uint256 balance = IWETH9(payable(weth)).balanceOf(address(this));
        if (balance > 0) {
            IWETH9(payable(weth)).withdrawTo(to, balance);
        }
    }
}
