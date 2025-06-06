// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract Vault {
    address public owner;

    constructor(address account) {
        owner = account;
    }

    function multicall(address[] calldata targets, bytes[] calldata data)
        public
        onlyOwner
        returns (bytes[] memory results)
    {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = targets[i].call(data[i]);

            if (!success) {
                // Next 5 lines from https://ethereum.stackexchange.com/a/83577
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }

            results[i] = result;
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Vault: caller is not the owner");
        _;
    }
}
