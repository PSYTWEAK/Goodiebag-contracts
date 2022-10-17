// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import {IVaultFactory} from "../../interfaces/IVaultFactory.sol";

contract VaultHandler {
    address vaultFactory;

    constructor(address _vaultFactory) {
        vaultFactory = _vaultFactory;
    }

    function useVault(address account) internal returns (address) {
        return IVaultFactory(vaultFactory).getVault(account);
    }
}
