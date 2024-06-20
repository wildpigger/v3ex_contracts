// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol"; // solhint-disable
import {V3EXToken} from "../src/V3EXToken.sol";
import {V3EXCheckIn} from "../src/V3EXCheckIn.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract V3EXDeploy is Script {
    uint256 private initV3EXCheckInBalance = 10_000_000_000 * 10e17;
    uint256 private initOwnerBalance = 90_000_000_000 * 10e17;

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATEKEY");
        address signer = vm.envAddress("SIGNER");
        // 检查余额
        address deployer = vm.addr(privateKey);
        uint256 balance = deployer.balance;
        console.log("deployer balance:", balance);
        require(balance > 0, "Insufficient balance");

        vm.startBroadcast(privateKey);
        V3EXToken vt = new V3EXToken();
        bytes memory vtData = abi.encodeCall(vt.initialize, ("V3EXToken", "V3EX"));
        address proxyV3EXToken = payable(address(new ERC1967Proxy(address(vt), vtData)));
        
        V3EXCheckIn vc = new V3EXCheckIn();
        bytes memory vcData = abi.encodeCall(vc.initialize, (proxyV3EXToken, signer, 300));
        address proxyV3EXCheckIn = payable(address(new ERC1967Proxy(address(vc), vcData)));

        V3EXToken(proxyV3EXToken).mint(proxyV3EXCheckIn, initV3EXCheckInBalance);
        V3EXToken(proxyV3EXToken).mint(deployer, initOwnerBalance);
        vm.stopBroadcast();
        console.log("proxyV3EXToken: ", proxyV3EXToken);
        console.log("proxyV3EXCheckIn: ", proxyV3EXCheckIn);
    }
}