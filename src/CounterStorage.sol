// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library CounterStorage {
    bytes32 internal constant SLOT = keccak256("onchain.git.counter.storage.v1");

    struct Layout {
        bool initialized;
        uint256 value;
        string name;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = SLOT;
        assembly {
            l.slot := slot
        }
    }
}
