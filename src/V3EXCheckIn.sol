// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {BitMaps} from "@openzeppelin/contracts/utils/structs/BitMaps.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/security/ReentrancyGuardUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/security/PausableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {IV3EXCheckIn} from "./IV3EXCheckIn.sol";


contract V3EXCheckIn is OwnableUpgradeable, PausableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable, IV3EXCheckIn{
    using ECDSA for bytes32;
    using BitMaps for BitMaps.BitMap;
    
    // The address of the signer
    address private signer;
    // The fee percentage for tips, in basis points (1% = 100 basis points)
    uint256 public feePercentage; 
    // The maximum allowed fee percentage (100%)
    uint256 public constant MAX_FEE = 10000;

    /// @notice The address of the V3EX ERC20 token
    address public VTOKEN;

    /// _exists userCheckIn
    BitMaps.BitMap private _userCheckInEntries;
    /// _exists transId
    BitMaps.BitMap private _transIds;
    /// collectedFees for token, using 0x0000000000000000000000000000000000000000 for baseCoin(eg: ETH)
    mapping(address => uint256) public collectedFees;

    // Custom error messages
    error AlreadyCheckIn(address user, uint256 date);
    error InvalidAmount(uint256 amount);
    error ExistsTransId(string transId);
    error InvalidSignature(bytes signature);
    error InsufficientBalance();
    error InvalidUserAddress(address user);
    error InvalidTokenAddress(address ads);
    error InvalidRecipientAddress(address ads);
    error InvalidFeePercentage(uint256 feePercentage);
    error TipTransferFailed();
    error FailedToSendETH();
    error WithdrawFeeFailed();

    /**
     * @dev Initializes the contract with the given parameters.
     * @param vtoken The address of the V3EX ERC20 token.
     * @param verifySigner The address of the signer for verification.
     * @param tipFee The fee percentage for tips.
     */
    function initialize(
        address vtoken,
        address verifySigner,
        uint256 tipFee
        ) public virtual initializer  {
        if (tipFee > MAX_FEE) {
            revert InvalidFeePercentage(tipFee);
        }
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        VTOKEN = vtoken;
        signer = verifySigner;
        feePercentage = tipFee;
    }


    /// daily checkIn
    function checkIn(
        uint256 date, 
        uint256 amount, 
        string memory transId, 
        bytes memory signature
        ) external virtual whenNotPaused nonReentrant {
        if (haveCheckedIn(msg.sender,date)) {
            revert AlreadyCheckIn(msg.sender, date);
        } else if (amount == 0) {
            revert InvalidAmount(amount);
        } else  if (existsTransId(transId)) {
            revert ExistsTransId(transId);
        } else if (!verifySignature("CHECKIN", transId, amount, msg.sender, signature)) {
            revert InvalidSignature(signature);
        } else if (IERC20(VTOKEN).balanceOf(address(this)) < amount + collectedFees[VTOKEN]) {
            revert InsufficientBalance();
        }

        // set transId
        _transIds.set(_transIdKey(transId));
        // ser checkIn
        _userCheckInEntries.set(_userDateKey(msg.sender, date));
        // send token to sender
        SafeERC20.safeTransfer(IERC20(VTOKEN), msg.sender, amount);
        emit UserCheckIn(msg.sender, date, amount);
    }

    function haveCheckedIn(address user, uint256 date) public view virtual returns (bool){
        return _userCheckInEntries.get(_userDateKey(user, date));
    }

    function checkInStates(address user, uint256[] memory dates) public view virtual returns (bool[] memory states) {
        if (user == address(0)) {
            revert InvalidUserAddress(user);
        }
        states = new bool[](dates.length);
        for (uint256 i=0; i < dates.length; i++) {
            states[i] = haveCheckedIn(user, dates[i]);
        }
        return states;
    }


    function existsTransId(string memory transId) public view virtual returns (bool){
        return _transIds.get(_transIdKey(transId));
    }

    // sign data
    function toMessageHash(
        uint256 chainId,
        string memory code,
        string memory transId,
        uint256 amount,
        address to
        ) public pure virtual returns (bytes32) {
       return keccak256(abi.encodePacked(chainId, code, transId, amount, to));
    }

    function verifySignature(
        string memory code,
        string memory transId,
        uint256 amount,
        address to,
        bytes memory signature
        ) public view virtual returns (bool){
        bytes32 hash = toMessageHash(block.chainid, code, transId, amount, to);
        return (signer == hash.toEthSignedMessageHash().recover(signature));
    }


    // signer
    function getSigner() public view virtual onlyOwner returns (address)  {
        return signer;
    }

    function setSigner(address addr) external virtual onlyOwner {
        signer = addr;
        emit SignerUpdated(signer);
    }


    /// tip
    function tipERC20(
        address tokenAddress,
        address to,
        uint256 amount
        ) external virtual whenNotPaused nonReentrant {
        if (tokenAddress == address(0)) {
            revert InvalidTokenAddress(tokenAddress);
        } else if (to == address(0)) {
            revert InvalidRecipientAddress(to);
        } else if (amount == 0) {
            revert InvalidAmount(amount);
        }
        uint256 fee = (amount * feePercentage) / MAX_FEE;
        uint256 netAmount = amount - fee;
        collectedFees[tokenAddress] += fee;

        SafeERC20.safeTransferFrom(IERC20(tokenAddress), msg.sender, address(this), fee);
        SafeERC20.safeTransferFrom(IERC20(tokenAddress), msg.sender, to, netAmount);

        emit TipSent(msg.sender, to, amount, tokenAddress);
        emit FeeCollected(tokenAddress, fee);
    }

    function tipETH(address to) external virtual payable whenNotPaused nonReentrant {
        if (to == address(0)) {
            revert InvalidRecipientAddress(to);
        } else if (msg.value == 0) {
            revert InvalidAmount(msg.value);
        }
        uint256 fee = (msg.value * feePercentage) / MAX_FEE;
        uint256 netAmount = msg.value - fee;

        collectedFees[address(0)] += fee;

        (bool success, ) = to.call{value: netAmount}("");
        if (!success) {
            revert TipTransferFailed();
        }

        emit TipSent(msg.sender, to, msg.value, address(0));
        emit FeeCollected(address(0), fee);
    }

    function setFeePercentage(uint256 newFeePercentage) external virtual onlyOwner {
        if (newFeePercentage > MAX_FEE) {
            revert InvalidFeePercentage(newFeePercentage);
        }
        uint256 oldFee = feePercentage;
        feePercentage = newFeePercentage;

        emit FeePercentageChanged(oldFee, newFeePercentage);
    }

    function withdrawCollectedFees(address tokenAddress, address to, uint256 amount) external virtual onlyOwner {
        if (to == address(0)) {
            revert InvalidRecipientAddress(to);
        } else if (collectedFees[tokenAddress] < amount) {
            revert InvalidAmount(amount);
        }
        collectedFees[tokenAddress] -= amount;
        _withdrawToken(tokenAddress, to, amount);
        emit WithdrawFee(tokenAddress, to, amount);
    }

    /**
     * @dev Internal function to withdraw tokens from the contract.
     * @param _tokenAddress The address of the token to withdraw.
     * @param _to The address to send the withdrawn tokens to.
     * @param _amount The amount of tokens to withdraw.
     */
    function _withdrawToken(address _tokenAddress, address _to, uint256 _amount) internal virtual onlyOwner {
        if (_tokenAddress == address(0)) {
            (bool success, ) = _to.call{value: _amount}("");
            if (!success) {
                revert FailedToSendETH();
            }
        } else {
            SafeERC20.safeTransfer(IERC20(_tokenAddress), _to, _amount);
        }
    }

    function withdrawStuckToken(address tokenAddress, address to) external virtual onlyOwner {
        uint256 contractBalance;
        if (tokenAddress == address(0)) {
            contractBalance = address(this).balance;
        } else {
            contractBalance = IERC20(tokenAddress).balanceOf(address(this));
        }
        _withdrawToken(tokenAddress, to, contractBalance);
    }

    /**
     * @dev Internal function to generate a unique key for user and date.
     * @param _user The address of the user.
     * @param _date The date to generate the key for.
     * @return The generated key.
     */
    function _userDateKey(address _user, uint256 _date) internal pure virtual returns(uint256) {
        return uint256(keccak256(abi.encode(_user, _date)));
    }

    /**
     * @dev Internal function to generate a unique key for transaction ID.
     * @param _transId The transaction ID to generate the key for.
     * @return The generated key.
     */
    function _transIdKey(string memory _transId) internal pure virtual returns(uint256) {
        return uint256(keccak256(bytes(_transId)));
    }

    receive() external payable {}

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        virtual
        override {}
}