// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/contracts/token/ERC20/IERC20Upgradeable.sol";

interface IV3EXToken is IERC20Upgradeable {
    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * @param to The address of the user receiving token, cannot be the zero address.
     * @param amount The amount of mint.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function pause() external;

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function unpause() external;
}