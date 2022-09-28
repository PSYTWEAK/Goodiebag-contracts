// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IWETH9} from "./IWETH9.sol";
import "arbos-precompiles/arbos/builtin/ArbAddressTable.sol";

contract Swapper {
    address public weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address public goodieBag;
    ArbAddressTable public arbAddressTable;

    constructor(address _goodieBag) {
        goodieBag = _goodieBag;
        arbAddressTable = ArbAddressTable(
            0x0000000000000000000000000000000000000064
        );
    }

    /*  
    ================================================================
                        Public Functions
    ================================================================ 
    */

    function swap(
        uint256 router,
        uint256 token,
        bytes memory swapCalldata,
        address to
    )
        public
        onlyGoodieBag
        approveRouter(router)
        transferTokens(token, to)
        returns (bytes memory)
    {
        (bool success, bytes memory returndata) = _address(router).call(
            swapCalldata
        );
        if (!success) {
            if (returndata.length == 0) revert();
            assembly {
                revert(add(32, returndata), mload(returndata))
            }
        }
        return returndata;
    }

    function refundETH(address to) public onlyGoodieBag {
        uint256 balance = IWETH9(payable(weth)).balanceOf(address(this));
        if (balance > 0) {
            IWETH9(payable(weth)).withdrawTo(to, balance);
        }
    }

    /*  
    ================================================================
                            Modifers 
    ================================================================ 
    */

    // This modifier checks the balance of both this contract and the tx origin account before and after the call
    // if the tokens were sent to the contract, it transfers them to the tx origin account
    // this is needed as some swap routers will send the tokens to the contract instead of a speicified reciver address
    // e.g. 1inch & 0x API

    modifier transferTokens(uint256 token, address to) {
        IERC20 tokenContract = IERC20(_address(token));
        uint256 senderbalanceBefore = tokenContract.balanceOf(to);
        uint256 thisbalanceBefore = tokenContract.balanceOf(address(this));

        _;

        uint256 senderbalanceAfter = tokenContract.balanceOf(to);
        uint256 thisbalanceAfter = tokenContract.balanceOf(address(this));

        if (thisbalanceBefore < thisbalanceAfter) {
            tokenContract.transfer(to, thisbalanceBefore - thisbalanceAfter);
        }

        require(
            senderbalanceBefore < senderbalanceAfter ||
                thisbalanceBefore < thisbalanceAfter,
            "Swapper: No tokens received"
        );
    }

    modifier approveRouter(uint256 router) {
        uint256 MAX_INT = 2**256 - 1;
        IERC20(weth).approve(_address(router), MAX_INT);
        _;
        IERC20(weth).approve(_address(router), 0);
    }

    modifier onlyGoodieBag() {
        require(msg.sender == goodieBag, "Swapper: Only GoodieBag can call");
        _;
    }

    function _address(uint256 index) public view returns (address) {
        return arbAddressTable.lookupIndex(index);
    }
}
