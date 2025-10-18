// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

/**
 * @title KipuBank
 * @author Victor Elian Guevara
 * @notice This contract allows users to deposit and withdraw ETH into a personal vault,
 * with withdrawal limits and a global deposit cap for the entire bank.
 * @dev Implements the checks-effects-interactions pattern and uses custom errors.
 */
contract KipuBank {
    // ==============================================================================
    // Variables inmutables || constantes
    // ==============================================================================

    /**
     * @notice Maximum amount of ETH that can be withdrawn in a single transaction.
     * @dev Set in the constructor and cannot be modified.
     */
    uint256 public immutable withdrawalThreshold;

    /**
     * @notice Maximum amount of ETH the bank can hold in total.
     * @dev Set in the constructor and cannot be modified.
     */
    uint256 public immutable bankCap;

    /**
     * @notice Contract version.
     * @dev Constant variable identifying the current version of the contract.
     */
    string public constant VERSION = "1.0.0";

    // ==============================================================================
    // Variables de almacenamiento
    // ==============================================================================

    /**
     * @notice Total count of deposits made to the contract.
     * @dev Incremented with each successful deposit.
     */
    uint256 public depositCount;

    /**
     * @notice Total count of withdrawals made from the contract.
     * @dev Incremented with each successful withdrawal.
     */
    uint256 public withdrawalCount;

    // ==============================================================================
    // Mapping
    // ==============================================================================

    /**
     * @notice Mapping from user address to their personal vault balance.
     * @dev Tracks the individual balance of each user in the bank.
     */
    mapping(address => uint256) public vaultBalances;

    // ==============================================================================
    // Eventos
    // ==============================================================================

    /**
     * @notice Emitted when a user makes a successful deposit.
     * @param user The address of the depositing user.
     * @param amount The amount of ETH deposited.
     */
    event Deposit(address indexed user, uint256 amount);

    /**
     * @notice Emitted when a user makes a successful withdrawal.
     * @param user The address of the withdrawing user.
     * @param amount The amount of ETH withdrawn.
     */
    event Withdrawal(address indexed user, uint256 amount);

    // ==============================================================================
    // Errores personalizados
    // ==============================================================================

    /**
     * @notice Error: The deposit amount must be greater than zero.
     */
    error KipuBank__ZeroDeposit();

    /**
     * @notice Error: Deposit exceeds the bank's capacity limit.
     * @param availableSpace The remaining available space in the bank.
     */
    error KipuBank__BankCapExceeded(uint256 availableSpace);

    /**
     * @notice Error: The withdrawal amount must be greater than zero.
     */
    error KipuBank__ZeroWithdrawal();

    /**
     * @notice Error: Insufficient funds in the user's vault for withdrawal.
     * @param balance The current balance of the user.
     */
    error KipuBank__InsufficientFunds(uint256 balance);

    /**
     * @notice Error: The withdrawal amount exceeds the per-transaction threshold.
     * @param threshold The maximum allowed withdrawal threshold.
     */
    error KipuBank__WithdrawalThresholdExceeded(uint256 threshold);

    /**
     * @notice Error: ETH transfer failed.
     * @param reason The failure reason in bytes format.
     */
    error KipuBank__TransferFailed(bytes reason);

    // ==============================================================================
    // Constructor
    // ==============================================================================

    /**
     * @notice Initializes the contract with withdrawal and capacity limits.
     * @param _withdrawalThreshold Withdrawal limit per transaction.
     * @param _bankCap Total deposit capacity of the bank.
     */
    constructor(uint256 _withdrawalThreshold, uint256 _bankCap) {
        withdrawalThreshold = _withdrawalThreshold;
        bankCap = _bankCap;
    }

    // ==============================================================================
    // Modificador
    // ==============================================================================

    /**
     * @notice Modifier to ensure the sent value is greater than zero.
     * @dev Validates that msg.value > 0 before executing the function.
     */
    modifier nonZeroValue() {
        if (msg.value == 0) {
            revert KipuBank__ZeroDeposit();
        }
        _;
    }

    /**
     * @notice Modifier to validate withdrawal conditions.
     * @dev Checks that amount is non-zero, within threshold, and user has sufficient funds.
     * @param _amount The amount to withdraw.
     */
    modifier validWithdrawal(uint256 _amount) {
        if (_amount == 0) {
            revert KipuBank__ZeroWithdrawal();
        }
        
        if (_amount > withdrawalThreshold) {
            revert KipuBank__WithdrawalThresholdExceeded(withdrawalThreshold);
        }

        // Single read from storage
        uint256 userBalance = vaultBalances[msg.sender];
        
        if (_amount > userBalance) {
            revert KipuBank__InsufficientFunds(userBalance);
        }
        _;
    }

    // ==============================================================================
    // Función external payable
    // ==============================================================================

    /**
     * @notice Allows a user to deposit ETH into their vault.
     * @dev The function is 'payable' to receive ETH.
     * Follows the 'checks-effects-interactions' pattern.
     */
    function deposit() external payable nonZeroValue {
        // --- Checks ---
        uint256 currentBalance = address(this).balance - msg.value;
        uint256 newBalance = currentBalance + msg.value;
        
        if (newBalance > bankCap) {
            uint256 availableSpace = bankCap - currentBalance;
            revert KipuBank__BankCapExceeded(availableSpace);
        }

        // --- Effects ---
        // Single read + single write to storage
        uint256 userVaultBalance = vaultBalances[msg.sender];
        
        unchecked {
            // Safe: we already checked newBalance won't overflow bankCap
            vaultBalances[msg.sender] = userVaultBalance + msg.value;
            // Safe: depositCount won't realistically overflow uint256
            depositCount++;
        }

        // --- Interactions ---
        // (No external interactions in this function)

        emit Deposit(msg.sender, msg.value);
    }

    // ==============================================================================
    // Función external (con modifier)
    // ==============================================================================

    /**
     * @notice Allows a user to withdraw ETH from their vault.
     * @param _amount The amount of ETH to withdraw.
     * @dev Follows the 'checks-effects-interactions' pattern.
     */
    function withdraw(uint256 _amount) external validWithdrawal(_amount) {
        // --- Checks ---
        // (Already validated in modifier)

        // --- Effects ---
        // Single read + single write to storage
        uint256 userBalance = vaultBalances[msg.sender];
        
        unchecked {
            // Safe: modifier already checked _amount <= userBalance
            vaultBalances[msg.sender] = userBalance - _amount;
            // Safe: withdrawalCount won't realistically overflow uint256
            withdrawalCount++;
        }

        // --- Interactions ---
        _safeTransfer(msg.sender, _amount);

        emit Withdrawal(msg.sender, _amount);
    }

    // ==============================================================================
    // Función external view
    // ==============================================================================

    /**
     * @notice Returns the vault balance of a specific user.
     * @param _user The address of the user.
     * @return The balance in wei of the specified user.
     */
    function getVaultBalance(address _user) external view returns (uint256) {
        return vaultBalances[_user];
    }

    /**
     * @notice Returns the total balance of the contract.
     * @return The total balance in wei held by the contract.
     */
    function getTotalBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // ==============================================================================
    // Función privada
    // ==============================================================================

    /**
     * @notice Safely transfers ETH to a given address.
     * @dev Private function to handle transfer logic.
     * Uses low-level call for greater security.
     * @param _to The recipient address.
     * @param _amount The amount to send.
     */
    function _safeTransfer(address _to, uint256 _amount) private {
        (bool success, bytes memory data) = _to.call{value: _amount}("");
        if (!success) {
            revert KipuBank__TransferFailed(data);
        }
    }
}
