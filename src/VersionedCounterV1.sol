// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./CounterStorage.sol";

contract VersionedCounterV1 {
    error AlreadyInitialized();

    event Initialized(string name, uint256 initialValue);
    event Incremented(uint256 newValue);

    function initialize(string memory name, uint256 initialValue) external {
        CounterStorage.Layout storage cs = CounterStorage.layout();
        if (cs.initialized) revert AlreadyInitialized();
        cs.initialized = true;
        cs.name = name;
        cs.value = initialValue;
        emit Initialized(name, initialValue);
    }

    function increment() external {
        CounterStorage.Layout storage cs = CounterStorage.layout();
        cs.value += 1;
        emit Incremented(cs.value);
    }

    function getValue() external view returns (uint256) {
        return CounterStorage.layout().value;
    }

    function getName() external view returns (string memory) {
        return CounterStorage.layout().name;
    }

    function version() external pure virtual returns (string memory) {
        return "V1";
    }
}
