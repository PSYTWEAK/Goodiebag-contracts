pragma solidity >=0.4.0;

interface IVaultFactory {
    function getVault(address account) external returns (address);
}
