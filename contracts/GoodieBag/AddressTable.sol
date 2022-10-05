// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "arbos-precompiles/arbos/builtin/ArbAddressTable.sol";

contract AddressTable {
    address public weth = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;

    ArbAddressTable public arbAddressTable;

    constructor() {
        arbAddressTable = ArbAddressTable(
            0x0000000000000000000000000000000000000066
        );
    }

    function _address(uint256 index) public view returns (address) {
        return arbAddressTable.lookupIndex(index);
    }
}
