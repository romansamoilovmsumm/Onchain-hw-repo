// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VersioningStorage} from "./VersioningStorage.sol";

contract OnchainGitProxy {
    error NotOwner();
    error ZeroAddress();
    error InvalidVersionIndex();
    error EmptyHistory();

    event Upgraded(address indexed implementation, uint256 indexed versionIndex);
    event RolledBack(address indexed implementation, uint256 indexed versionIndex);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address initialImplementation, bytes memory initData, address owner_) payable {
        if (initialImplementation == address(0) || owner_ == address(0)) revert ZeroAddress();

        VersioningStorage.Layout storage v = VersioningStorage.layout();
        v.owner = owner_;
        v.versionHistory.push(initialImplementation);
        v.currentVersionIndex = 0;

        emit OwnershipTransferred(address(0), owner_);
        emit Upgraded(initialImplementation, 0);

        if (initData.length > 0) {
            (bool ok, bytes memory ret) = initialImplementation.delegatecall(initData);
            if (!ok) {
                assembly {
                    revert(add(ret, 0x20), mload(ret))
                }
            }
        }
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        if (msg.sender != VersioningStorage.layout().owner) revert NotOwner();
    }

    function owner() external view returns (address) {
        return VersioningStorage.layout().owner;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        VersioningStorage.Layout storage v = VersioningStorage.layout();
        address previous = v.owner;
        v.owner = newOwner;
        emit OwnershipTransferred(previous, newOwner);
    }

    function versionHistoryLength() external view returns (uint256) {
        return VersioningStorage.layout().versionHistory.length;
    }

    function versionHistory(uint256 index) external view returns (address) {
        VersioningStorage.Layout storage v = VersioningStorage.layout();
        if (index >= v.versionHistory.length) revert InvalidVersionIndex();
        return v.versionHistory[index];
    }

    function currentVersionIndex() external view returns (uint256) {
        return VersioningStorage.layout().currentVersionIndex;
    }

    function currentImplementation() public view returns (address) {
        VersioningStorage.Layout storage v = VersioningStorage.layout();
        if (v.versionHistory.length == 0) revert EmptyHistory();
        return v.versionHistory[v.currentVersionIndex];
    }

    function upgradeTo(address newImplementation) external onlyOwner {
        if (newImplementation == address(0)) revert ZeroAddress();

        VersioningStorage.Layout storage v = VersioningStorage.layout();
        v.versionHistory.push(newImplementation);
        v.currentVersionIndex = v.versionHistory.length - 1;

        emit Upgraded(newImplementation, v.currentVersionIndex);
    }

    function rollbackTo(uint256 selectedIndex) external onlyOwner {
        VersioningStorage.Layout storage v = VersioningStorage.layout();
        if (selectedIndex >= v.versionHistory.length) revert InvalidVersionIndex();
        v.currentVersionIndex = selectedIndex;

        emit RolledBack(v.versionHistory[selectedIndex], selectedIndex);
    }

    fallback() external payable {
        _delegate(currentImplementation());
    }

    receive() external payable {
        _delegate(currentImplementation());
    }

    function _delegate(address implementation_) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(0, 0, size)
            switch result
            case 0 { revert(0, size) }
            default { return(0, size) }
        }
    }
}