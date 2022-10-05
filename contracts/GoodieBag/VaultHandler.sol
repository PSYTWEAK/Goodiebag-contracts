// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {Vault} from "../vault/Vault.sol";

contract VaultHandler {
    mapping(address => accountConfig) public accountConfigs;

    struct accountConfig {
        bool usingVault;
        address vault;
    }

    function getReceiverAddress(address account) internal returns (address) {
        if (accountConfigs[account].usingVault) {
            return getVault(account);
        } else {
            return account;
        }
    }

    function getVault(address account)
        internal
        checkHasVault(account)
        returns (address)
    {
        return accountConfigs[account].vault;
    }

    function createVault() internal returns (address) {
        Vault vault = new Vault();
        return address(vault);
    }

    modifier setUsingVault(bool _usingVault) {
        accountConfigs[msg.sender].usingVault = _usingVault;
        _;
    }

    modifier checkHasVault(address account) {
        if (accountConfigs[account].vault == address(0)) {
            accountConfigs[account].vault = createVault();
        }
        _;
    }
}
