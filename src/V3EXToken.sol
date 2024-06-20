// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/token/ERC20/extensions/ERC20PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/contracts/proxy/utils/UUPSUpgradeable.sol";
import {IV3EXToken} from "./IV3EXToken.sol";

contract V3EXToken is OwnableUpgradeable, ERC20PausableUpgradeable, UUPSUpgradeable, IV3EXToken {
    // upgradeable components
    function initialize(string memory name, string memory symbol) initializer public virtual {
        __Pausable_init();
        __ERC20_init(name, symbol);
        __Ownable_init();
    }

    function mint(address to, uint256 amount) public virtual onlyOwner {
        _mint(to, amount);
    }

    function pause() public virtual onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public virtual onlyOwner whenPaused {
        _unpause();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        virtual
        override
    {}
}