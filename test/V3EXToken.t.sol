// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // solhint-disable
import "../src/V3EXToken.sol"; // solhint-disable
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract V3EXTokenTest is Test {
    address public owner;
    address public proxy;
    V3EXToken public proxyV3EXToken;

    function setUp() public {
        owner = address(0x01);
        V3EXToken v = new V3EXToken();
        bytes memory data = abi.encodeCall(v.initialize, ("V3EX", "V"));
        proxy = address(new ERC1967Proxy(address(v), data));
        proxyV3EXToken = V3EXToken(proxy);
    }

    function test_mint() public {
        vm.prank(owner);
        proxyV3EXToken.mint(owner, 100);
        assertEq(proxyV3EXToken.balanceOf(owner), 100);
    }

    function test_pause() public {
        vm.prank(owner);
        proxyV3EXToken.pause();
        assertEq(proxyV3EXToken.paused(), true);
    }

    function test_unpause() public {
        vm.startPrank(owner);
        proxyV3EXToken.pause();
        assertEq(proxyV3EXToken.paused(), true);
        proxyV3EXToken.unpause();
        assertEq(proxyV3EXToken.paused(), false);
        vm.stopPrank();
    }
}
