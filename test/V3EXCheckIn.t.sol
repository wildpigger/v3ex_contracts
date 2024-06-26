// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol"; // solhint-disable
import "../src/V3EXCheckIn.sol"; // solhint-disable
import "../src/V3EXToken.sol"; // solhint-disable
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract V3EXTokenTest is Test {
    using ECDSA for bytes32;

    address public owner;
    uint256 internal ownerPrivateKey;
    address public signer;
    uint256 internal signerPrivateKey;
    address public user1;
    address payable public proxyV3EXTokenAddress;
    address payable public proxyV3EXCheckInAddress;
    V3EXToken public proxyV3EXToken;
    V3EXCheckIn public proxyV3EXCheckIn;
    uint256 public initCheckInBalance;

    function setUp() public {
        ownerPrivateKey = 0xaaaaaa;
        owner = vm.addr(ownerPrivateKey);
        signerPrivateKey = 0x4651f9c219fc6401fe0b3f82129467c717012287ccb61950d2a8ede0687857ba;
        signer = vm.addr(signerPrivateKey);
        user1 = address(0x02);
        vm.startPrank(owner);
        V3EXToken vt = new V3EXToken();
        bytes memory vtData = abi.encodeCall(vt.initialize, ("V3EX", "V"));
        proxyV3EXTokenAddress = payable(address(new ERC1967Proxy(address(vt), vtData)));
        proxyV3EXToken = V3EXToken(proxyV3EXTokenAddress);

        V3EXCheckIn vc = new V3EXCheckIn();
        bytes memory vcData = abi.encodeCall(vc.initialize, (proxyV3EXTokenAddress, signer, 300));
        proxyV3EXCheckInAddress = payable(address(new ERC1967Proxy(address(vc), vcData)));
        proxyV3EXCheckIn = V3EXCheckIn(proxyV3EXCheckInAddress);

        initCheckInBalance = 100_000_000;
        proxyV3EXToken.mint(proxyV3EXCheckInAddress, initCheckInBalance);
        vm.stopPrank();
    }

    function test_checkIn() public {
        uint256 date = uint256(20240615);
        _checkIn(user1, date, "1");
        assertEq(proxyV3EXToken.balanceOf(user1), 1000);
        assertEq(proxyV3EXToken.balanceOf(proxyV3EXCheckInAddress), initCheckInBalance - 1000);
        assertEq(proxyV3EXCheckIn.haveCheckedIn(user1, date), true);
        assertEq(proxyV3EXCheckIn.existsTransId("1"), true);
    }

    function _checkIn(address user, uint256 date, string memory transId) internal {
        vm.startPrank(user);
        uint256 amount = uint256(1000);
        bytes memory signature = getSignature("CHECKIN", transId, amount, user);
        proxyV3EXCheckIn.checkIn(date, amount, transId, signature);
        vm.stopPrank();
    }

    function test_tipERC20() public {
        address author = address(0x11);
        // mintTo user1 token
        vm.prank(owner);
        proxyV3EXToken.mint(user1, 1000);

        vm.startPrank(user1);
        proxyV3EXToken.approve(proxyV3EXCheckInAddress, 100);
        proxyV3EXCheckIn.tipERC20(proxyV3EXTokenAddress, author, 100);
        assertEq(proxyV3EXToken.balanceOf(author), 97);
        assertEq(proxyV3EXToken.balanceOf(proxyV3EXCheckInAddress), initCheckInBalance + 3);
        vm.stopPrank();
    }

    function test_tipETH() public {
        address author = address(0x11);
        vm.deal(user1, 1000 wei);
        vm.startPrank(user1);
        proxyV3EXCheckIn.tipETH{value: 100}(author);
        assertEq(author.balance, 97);
        assertEq(proxyV3EXCheckInAddress.balance, 3);
        assertEq(user1.balance, 900);
        vm.stopPrank();
    }

    function test_setFeePercentage() public {
        vm.startPrank(owner);
        proxyV3EXCheckIn.setFeePercentage(uint256(500));
        assertEq(proxyV3EXCheckIn.feePercentage(), 500);
        vm.stopPrank();
    }

    function test_checkInStates() public {
        uint256[] memory dates = new uint256[](5);
        dates[0]=uint256(20240615);
        dates[1]=uint256(20240616);
        dates[2]=uint256(20240617);
        dates[3]=uint256(20240618);
        dates[4]=uint256(20240619);
        bool[] memory states = new bool[](5);
        states[0] = true;
        states[1] = true;
        states[2] = true;
        states[3] = true;
        states[4] = false;
        for (uint256 i=0; i < dates.length-1; i++) {
            _checkIn(user1, dates[i], Strings.toString(i));
        }
        bool[] memory results = proxyV3EXCheckIn.checkInStates(user1, dates);
        assertEq(states.length, results.length);
        for (uint256 i=0; i < dates.length-1; i++) {
            assertEq(states[i], results[i]);
        }
    }

    function test_xxx() public {
        uint256 chainId = uint256(59141);
        vm.chainId(chainId);
        address to = address(0xc30bfe927d60fabA7D1b346E88720bd3c9492d1f);
        uint256 date = uint256(20240625);
        uint256 amount = uint256(123);
        string memory transId = Strings.toHexString(uint256(getTransId(chainId, to, date)));
        bytes memory signature = getSignature("CHECKIN", transId, amount, to);

        console.log("transId:", transId);
        console.log("signature:", iToHex(signature));
    }

     function iToHex(bytes memory buffer) public pure returns (string memory) {

        // Fixed buffer size for hexadecimal convertion
        bytes memory converted = new bytes(buffer.length * 2);

        bytes memory _base = "0123456789abcdef";

        for (uint256 i = 0; i < buffer.length; i++) {
            converted[i * 2] = _base[uint8(buffer[i]) / _base.length];
            converted[i * 2 + 1] = _base[uint8(buffer[i]) % _base.length];
        }

        return string(converted);
    }

    function getTransId(
        uint256 chainId,
        address to,
        uint256 date
    ) public pure returns(bytes32 transId) {
        return keccak256(abi.encodePacked(chainId, to, date));
    }

    function getSignature(
        string memory code, 
        string memory transId, 
        uint256 amount, 
        address to
        ) public view returns(bytes memory signature) {
        bytes32 hash = proxyV3EXCheckIn.toMessageHash(block.chainid, code, transId, amount, to);
        bytes32 digest = hash.toEthSignedMessageHash();
        console.log("hash:", Strings.toHexString(uint256(hash)));
        console.log("digest",Strings.toHexString(uint256(digest)));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        signature = abi.encodePacked(r, s, v); // note the order here is different from line above.
        return signature;
    }

    function recoverSigner(
        string memory code, 
        string memory transId, 
        uint256 amount, 
        address to, 
        bytes memory signature
        ) public view virtual returns (address){
        bytes32 hash = proxyV3EXCheckIn.toMessageHash(block.chainid, code, transId, amount, to);
        return hash.toEthSignedMessageHash().recover(signature);
    }
}