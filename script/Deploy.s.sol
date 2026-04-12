// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {OnchainGitProxy} from "../src/OnchainGitProxy.sol";
import {VersionedCounterV1} from "../src/VersionedCounterV1.sol";

contract Deploy is Script {
    function run() external returns (address proxy, address implementationV1) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(pk);

        vm.startBroadcast(pk);
        implementationV1 = address(new VersionedCounterV1());
        bytes memory initData = abi.encodeCall(VersionedCounterV1.initialize, ("Onchain Git MVP", 1));
        proxy = address(new OnchainGitProxy(implementationV1, initData, deployer));
        vm.stopBroadcast();
    }
}
