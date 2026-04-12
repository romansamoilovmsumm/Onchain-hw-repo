// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VersionedCounterV1} from "./VersionedCounterV1.sol";
import {CounterStorage} from "./CounterStorage.sol";

contract VersionedCounterV2 is VersionedCounterV1 {
    event Decremented(uint256 newValue);

    function decrement() external {
        CounterStorage.Layout storage cs = CounterStorage.layout();
        require(cs.value > 0, "counter underflow");
        cs.value -= 1;
        emit Decremented(cs.value);
    }

    function version() external pure override returns (string memory) {
        return "V2";
    }
}
