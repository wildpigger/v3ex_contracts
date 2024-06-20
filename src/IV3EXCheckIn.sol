// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IV3EXCheckIn {
    /**
     * @dev Emitted when a user checks in at a specific date.
     * @param user The address of the user who checked in.
     * @param date The date of the check-in.
     * @param amount The amount associated with the check-in. This value cannot be zero.
     */
    event UserCheckIn(address indexed user, uint256 date, uint256 amount);
    
    /**
     * @dev Emitted when the signer is updated.
     * @param signer The new signer address. This address cannot be the zero address.
     */
    event SignerUpdated(address signer);
    
    /**
     * @dev Emitted when a user sends a tip.
     * @param from The address of the user sending the tip.
     * @param to The address of the user receiving the tip.
     * @param amount The amount of the tip.
     * @param tokenAddress The address of the token used for the tip. This address cannot be the zero address.
     */
    event TipSent(address indexed from, address indexed to, uint256 amount, address tokenAddress);
    
    /**
     * @dev Emitted when fees are collected.
     * @param tokenAddress The address of the token used for fee collection.
     * @param amount The amount of fees collected.
     */
    event FeeCollected(address indexed tokenAddress, uint256 amount);
    
    /**
     * @dev Emitted when the fee percentage is changed.
     * @param oldFee The old fee percentage.
     * @param newFee The new fee percentage.
     */
    event FeePercentageChanged(uint256 oldFee, uint256 newFee);
    
    /**
     * @dev Emitted when fees are withdrawn.
     * @param tokenAddress The address of the token used for withdrawal.
     * @param to The address where the fees are withdrawn to.
     * @param amount The amount of fees withdrawn.
     */
    event WithdrawFee(address indexed tokenAddress, address indexed to, uint256 amount);

    /**
     * @dev Allows a user to check in with a specified date and amount.
     * @param date The date of the check-in.
     * @param amount The amount associated with the check-in.
     * @param transId The transaction ID for the check-in.
     * @param signature The signature for verifying the check-in.
     */
    function checkIn(
        uint256 date, 
        uint256 amount, 
        string memory transId, 
        bytes memory signature) external;

    /**
    * @dev Checks if a user has checked in on a specific date.
    * @param user The address of the user.
    * @param date The date to check.
    * @return state A boolean indicating whether the user has checked in on the specified date.
    */
    function haveCheckedIn(address user, uint256 date) external returns (bool state);

    /**
    * @dev Checks if a user has checked in on specific dates.
    * @param user The address of the user.
    * @param dates An array of dates to check.
    * @return states An array of booleans indicating whether the user has checked in on each of the specified dates.
    */
    function checkInStates(address user, uint256[] memory dates) external returns (bool[] memory states);

    /**
     * @dev Checks if a transaction ID exists.
     * @param transId The transaction ID to check.
     * @return exists True if the transaction ID exists, otherwise false.
     */
    function existsTransId(string memory transId) external returns (bool exists);

    /**
     * @dev Generates a message hash for signature verification.
     * @param chainId The ID of the blockchain.
     * @param code A code associated with the check-in.
     * @param transId The transaction ID for the check-in.
     * @param amount The amount associated with the check-in.
     * @param to The address to which the check-in is directed.
     * @return messageHash The generated message hash.
     */
    function toMessageHash(
        uint256 chainId,
        string memory code, 
        string memory transId, 
        uint256 amount, 
        address to) external returns (bytes32 messageHash);

    /**
     * @dev Verifies the signature for a check-in.
     * @param code A code associated with the check-in.
     * @param transId The transaction ID for the check-in.
     * @param amount The amount associated with the check-in.
     * @param to The address to which the check-in is directed.
     * @param signature The signature to verify.
     * @return verified True if the signature is valid, otherwise false.
     */
    function verifySignature(
            string memory code, 
            string memory transId, 
            uint256 amount, 
            address to, 
            bytes memory signature
            ) external returns (bool verified);

    /**
     * @dev Returns the current signer address.
     * @return signer The address of the current signer.
     */
    function getSigner() external returns (address signer);

    /**
     * @dev Sets a new signer address.
     * @param addr The new signer address.
     */
    function setSigner(address addr) external;

    /**
     * @dev Sends an ERC20 token tip to a specified address.
     * @param tokenAddress The address of the ERC20 token contract.
     * @param to The address to send the tip to.
     * @param amount The amount of the tip.
     */
    function tipERC20(
        address tokenAddress,
        address to, 
        uint256 amount
        ) external;

    /**
     * @dev Sends an ETH tip to a specified address.
     * @param to The address to send the tip to.
     */
    function tipETH(address to) external payable;

    /**
     * @dev Sets a new fee percentage for transactions.
     * @param newFeePercentage The new fee percentage.
     */
    function setFeePercentage(uint256 newFeePercentage) external;

    /**
     * @dev Withdraws collected fees to a specified address.
     * @param tokenAddress The address of the token used for fee withdrawal.
     * @param to The address to withdraw the fees to.
     * @param amount The amount of fees to withdraw.
     */
    function withdrawCollectedFees(address tokenAddress, address to, uint256 amount) external;

    /**
     * @dev Withdraws stuck tokens to a specified address.
     * @param tokenAddress The address of the token to withdraw.
     * @param to The address to withdraw the tokens to.
     */
    function withdrawStuckToken(address tokenAddress, address to) external;
}
