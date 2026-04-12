// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {OnchainGitProxy} from "../src/OnchainGitProxy.sol";
import {VersionedCounterV1} from "../src/VersionedCounterV1.sol";
import {VersionedCounterV2} from "../src/VersionedCounterV2.sol";

contract OnchainGitTest is Test {
    OnchainGitProxy proxy;
    VersionedCounterV1 v1;
    VersionedCounterV2 v2;

    function setUp() public {
        v1 = new VersionedCounterV1();
        bytes memory initData = abi.encodeCall(VersionedCounterV1.initialize, ("Counter", 7));
        proxy = new OnchainGitProxy(address(v1), initData, address(this));
    }

    function testInitialVersionAndState() public view {
        assertEq(proxy.owner(), address(this));
        assertEq(proxy.versionHistoryLength(), 1);
        assertEq(proxy.currentVersionIndex(), 0);
        assertEq(proxy.versionHistory(0), address(v1));
        assertEq(VersionedCounterV1(address(proxy)).getValue(), 7);
        assertEq(VersionedCounterV1(address(proxy)).version(), "V1");
    }

    function testUpgradeAndNewFunctionality() public {
        VersionedCounterV1(address(proxy)).increment();
        assertEq(VersionedCounterV1(address(proxy)).getValue(), 8);

        v2 = new VersionedCounterV2();
        proxy.upgradeTo(address(v2));

        assertEq(proxy.versionHistoryLength(), 2);
        assertEq(proxy.currentVersionIndex(), 1);
        assertEq(proxy.versionHistory(1), address(v2));
        assertEq(VersionedCounterV2(address(proxy)).version(), "V2");
        assertEq(VersionedCounterV2(address(proxy)).getValue(), 8);

        VersionedCounterV2(address(proxy)).decrement();
        assertEq(VersionedCounterV2(address(proxy)).getValue(), 7);
    }

    function testRollback() public {
        v2 = new VersionedCounterV2();
        proxy.upgradeTo(address(v2));
        VersionedCounterV2(address(proxy)).increment();
        assertEq(VersionedCounterV2(address(proxy)).getValue(), 8);

        proxy.rollbackTo(0);
        assertEq(proxy.currentVersionIndex(), 0);
        assertEq(VersionedCounterV1(address(proxy)).version(), "V1");
        assertEq(VersionedCounterV1(address(proxy)).getValue(), 8);

        VersionedCounterV1(address(proxy)).increment();
        assertEq(VersionedCounterV1(address(proxy)).getValue(), 9);
    }
}
