# 🏦 KipuBank  

## 📖 Description  

**KipuBank** is a smart contract for a **decentralized banking vault**.  
It allows users to **deposit and withdraw ETH** into their personal vault, with:  

✔️ **Withdrawal limits per transaction**  
✔️ **A global deposit cap for the entire bank**  
✔️ **Secure and transparent fund management**  

🔒 Built following Solidity best practices:  
- *checks-effects-interactions* pattern  
- Custom errors for clarity & efficiency  
- Full NatSpec documentation  
- Optimized storage access patterns
- Modifiers for reusable validation logic

---

## ✨ Key Features  

- 🔑 **Personal Vault**: Every user has their own ETH vault.  
- ⛔ **Withdrawal Limit**: `withdrawalThreshold` set at deployment to prevent abnormal movements.  
- 📊 **Bank Cap**: Global ETH cap (`bankCap`) defined at deployment.  
- 📢 **Events**: Logs deposits (`Deposit`) and withdrawals (`Withdrawal`) for easy tracking.  
- 🔄 **Counters**: Tracks the number of deposits and withdrawals.
- ⚡ **Gas Optimized**: Single storage reads/writes with `unchecked` blocks where safe.
- 🛡️ **Security First**: Modifiers validate all conditions before execution.

---

## 🏗️ Contract Architecture

### Layout Structure
Following Solidity best practices, the contract is organized as:

1. **Immutable || Constant Variables**
2. **Storage Variables**
3. **Mappings**
4. **Events**
5. **Custom Errors**
6. **Constructor**
7. **Modifiers**
8. **External Payable Function**
9. **External View Functions**
10. **Private Functions**

### Security Features

- ✅ **Custom Errors**: Gas-efficient error handling
- ✅ **Checks-Effects-Interactions**: Prevents reentrancy attacks
- ✅ **Storage Optimization**: Minimizes expensive storage operations
- ✅ **Safe Transfers**: Uses low-level calls with proper error handling
- ✅ **Input Validation**: Modifiers ensure all conditions are met

---

## 🚀 Deployment with Remix IDE  

### ✅ Prerequisites  

- 🦊 [MetaMask](https://metamask.io/) browser wallet installed.  
- 💰 Test ETH on **Sepolia** (get it from [sepoliafaucet.com](https://sepoliafaucet.com/)).  

### 🛠️ Deployment Steps  

1. **Open Remix IDE** → [Remix IDE](https://remix.ethereum.org/).  
2. **Load the Contract** → Create `KipuBank.sol` and paste the code.  
3. **Compile** → Use Solidity version `0.8.28` and click **Compile**.  
4. **Deploy on Sepolia**:  
   - Select **Injected Provider – MetaMask**.  
   - Connect MetaMask to **Sepolia**.  
   - Set constructor arguments:  
     - `_withdrawalThreshold` → Withdrawal limit per transaction (in Wei).  
       - Example: `1000000000000000000` (1 ETH)
     - `_bankCap` → Total deposit capacity (in Wei).  
       - Example: `10000000000000000000` (10 ETH)
   - Click **Deploy** and confirm in MetaMask.  

### 💡 Recommended Parameters

For testing purposes:
- **withdrawalThreshold**: 1 ETH (`1000000000000000000` Wei)
- **bankCap**: 10 ETH (`10000000000000000000` Wei)

---

## 🎮 Interacting with the Contract  

Once deployed, find it in **"Deployed Contracts"** in Remix.  

### 📥 Deposit Function

- **Function**: `deposit()`
- **How to use**: 
  1. Enter the amount of ETH in the **Value** field (e.g., 0.1 ETH)
  2. Click **deposit**
  3. Confirm the transaction in MetaMask
- **What it does**: Adds ETH to your personal vault
- **Requirements**: 
  - Amount must be greater than 0
  - Total bank balance cannot exceed `bankCap`

### 💸 Withdraw Function

- **Function**: `withdraw(uint256 _amount)`
- **How to use**:
  1. Enter the amount in Wei (e.g., `100000000000000000` for 0.1 ETH)
  2. Click **withdraw**
  3. Confirm the transaction in MetaMask
- **What it does**: Withdraws ETH from your vault to your wallet
- **Requirements**:
  - Amount must be greater than 0
  - Amount cannot exceed `withdrawalThreshold`
  - You must have sufficient balance in your vault

### 📊 View Functions

- **`getVaultBalance(address _user)`**: Check the vault balance of any wallet address
  - Input: User's wallet address
  - Returns: Balance in Wei

- **`getTotalBalance()`**: View the total ETH stored in the contract
  - No input required
  - Returns: Total contract balance in Wei

- **`vaultBalances(address)`**: Direct mapping access to check your own balance
  - Input: Your wallet address
  - Returns: Your vault balance in Wei

- **`depositCount`**: Total number of deposits made
- **`withdrawalCount`**: Total number of withdrawals made
- **`VERSION`**: Contract version (1.0.0)

---

## 🌐 Deployed Contract  

- **Network**: Sepolia Testnet  
- **Contract Address**: `0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D`  
- **Etherscan (Verified)**: [🔗 View on Sepolia Etherscan](https://sepolia.etherscan.io/address/0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D#code)  

### Contract Parameters

- **Withdrawal Threshold**: [Check on Etherscan]
- **Bank Cap**: [Check on Etherscan]

---

## 🔧 Technical Details

### Gas Optimization Techniques

1. **Storage Access Minimization**: 
   - Single read + single write pattern
   - Variables cached in memory before operations

2. **Unchecked Arithmetic**:
   - Used after manual overflow/underflow checks
   - Saves gas on safe operations

3. **Custom Errors**:
   - More gas-efficient than `require` strings
   - Provides clear error messages

### Code Example: Optimized Withdrawal

```solidity
function withdraw(uint256 _amount) external validWithdrawal(_amount) {
    // Single storage read
    uint256 userBalance = vaultBalances[msg.sender];
    
    unchecked {
        // Safe: already validated in modifier
        vaultBalances[msg.sender] = userBalance - _amount;
        withdrawalCount++;
    }
    
    _safeTransfer(msg.sender, _amount);
    emit Withdrawal(msg.sender, _amount);
}
```

---

## 🧪 Testing Scenarios

### Successful Deposit
```
1. Call deposit() with 0.5 ETH
2. Check your balance with getVaultBalance(yourAddress)
3. Verify depositCount increased
```

### Successful Withdrawal
```
1. Ensure you have funds in your vault
2. Call withdraw(amount) with amount < withdrawalThreshold
3. Verify ETH received in your wallet
4. Check withdrawalCount increased
```

### Error Cases to Test

- ❌ Depositing 0 ETH → `KipuBank__ZeroDeposit()`
- ❌ Exceeding bank cap → `KipuBank__BankCapExceeded(availableSpace)`
- ❌ Withdrawing 0 ETH → `KipuBank__ZeroWithdrawal()`
- ❌ Withdrawing more than you have → `KipuBank__InsufficientFunds(balance)`
- ❌ Exceeding withdrawal threshold → `KipuBank__WithdrawalThresholdExceeded(threshold)`

---

## 📚 Learning Resources

This project demonstrates:
- ✅ Solidity 0.8.x features
- ✅ Custom errors
- ✅ Modifiers for code reusability
- ✅ Events for off-chain tracking
- ✅ Checks-Effects-Interactions pattern
- ✅ Gas optimization techniques
- ✅ NatSpec documentation
- ✅ Safe ETH transfers

---

## 🤝 Contributing

This is an educational project. Suggestions and improvements are welcome!

---

## 📜 License  

This project is licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

**Victor Elian Guevara**

Built as part of the Kipu Web3 Development course - Module 2 Final Project.

---

## 🔮 Future Enhancements

This contract is designed to be extensible. Future modules may add:
- 💰 Interest accrual on deposits
- 👥 Multi-signature withdrawals
- 🔄 Token support (ERC20)
- 📊 Advanced analytics
- 🎯 Governance features

---

**⭐ If this project helped you learn Solidity, consider giving it a star!**
