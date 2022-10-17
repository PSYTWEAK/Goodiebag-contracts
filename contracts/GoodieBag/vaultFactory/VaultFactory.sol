// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {Vault} from "../../vault/Vault.sol";

contract VaultFactory {
    mapping(address => address) public accountVault;

    /*  
    ================================================================
                        Internal Functions
    ================================================================ 
    */

    function getVault(address account)
        external
        checkHasVault(account)
        returns (address)
    {
        return getExistingVault(account);
    }

    function getExistingVault(address account) public view returns (address) {
        return accountVault[account];
    }

    function createVault(address account) internal returns (address) {
        Vault vault = new Vault(account);
        return address(vault);
    }

    /*  
    ================================================================
                            Modifers 
    ================================================================ 
    */

    modifier checkHasVault(address account) {
        if (accountVault[account] == address(0)) {
            accountVault[account] = createVault(account);
        }
        _;
    }
}
