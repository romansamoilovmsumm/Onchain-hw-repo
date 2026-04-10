// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library VersioningStorage {
    bytes32 internal constant SLOT = keccak256("onchain.git.versioning.storage.v1");

    struct Layout {
        address owner;
        address[] versionHistory;
        uint256 currentVersionIndex;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
