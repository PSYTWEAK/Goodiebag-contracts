// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import {IWETH9} from "./IWETH9.sol";
import {Swapper} from "./Swapper.sol";

contract GoodieBag {
    address public weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    Swapper public swapper;

    event MultiBuy(address account, uint256 value);

    constructor() {
        swapper = new Swapper(address(this));
    }

    /*  
    ================================================================
                        Public Functions
    ================================================================ 
    */

    function multiBuy(
        uint256[] memory router,
        uint256[] memory tokens,
        bytes[] memory swapCalldatas
    ) external payable refundETH {
        depositETH();
        for (uint256 i = 0; i < swapCalldatas.length; i++) {
            _swap(router[i], tokens[i], swapCalldatas[i]);
        }
        emit MultiBuy(msg.sender, msg.value);
    }

    /*  
    ================================================================
                        Internal Functions
    ================================================================ 
    */

    function depositETH() internal {
        IWETH9(payable(weth)).deposit{value: msg.value}();
        IWETH9(payable(weth)).transfer(address(swapper), msg.value);
    }

    function _swap(
        uint256 router,
        uint256 token,
        bytes memory swapCalldata
    ) internal {
        try swapper.swap(router, token, swapCalldata, msg.sender) returns (
            bytes memory
        ) {} catch {}
    }

    /*  
    ================================================================
                            Modifers 
    ================================================================ 
    */

    modifier refundETH() {
        _;
        swapper.refundETH(msg.sender);
    }

    /*  
    ================================================================
                    Public return view Functions
    ================================================================ 
    */

    function getSwapper() external view returns (address) {
        return address(swapper);
    }
}
