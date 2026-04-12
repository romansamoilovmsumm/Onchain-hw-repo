// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {OnchainGitProxy} from "../src/OnchainGitProxy.sol";
import {VersionedCounterV2} from "../src/VersionedCounterV2.sol";


contract Upgrade is Script {
    function run() external returns (address implementationV2) {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address proxy = vm.envAddress("PROXY");

        vm.startBroadcast(pk);
        implementationV2 = address(new VersionedCounterV2());
        OnchainGitProxy(payable(proxy)).upgradeTo(implementationV2);
        vm.stopBroadcast();
    }
}
