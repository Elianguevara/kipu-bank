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

---

## ✨ Key Features  

- 🔑 **Personal Vault**: Every user has their own ETH vault.  
- ⛔ **Withdrawal Limit**: `withdrawalThreshold` set at deployment to prevent abnormal movements.  
- 📊 **Bank Cap**: Global ETH cap (`bankCap`) defined at deployment.  
- 📢 **Events**: Logs deposits (`Deposit`) and withdrawals (`Withdrawal`) for easy tracking.  
- 🔄 **Counters**: Tracks the number of deposits and withdrawals.  

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
     - `_withdrawalThreshold` → withdrawal limit per transaction (Wei).  
     - `_bankCap` → total deposit cap (Wei).  
   - Click **Deploy** and confirm in MetaMask.  

---

## 🎮 Interacting with the Contract  

Once deployed, find it in **"Deployed Contracts"** in Remix.  

- 💵 `deposit()` → enter ETH in **Value**, then click deposit.  
- 💸 `withdraw(_amount)` → withdraw a chosen amount (in Wei).  
- 📌 `getVaultBalance(address)` → check the vault balance of a wallet.  
- 🏦 `getTotalBalance()` → view the total ETH stored in the contract.  

---

## 🌐 Deployed Contract  

- **Network**: Sepolia Testnet  
- **Address**: `0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D`  
- **Etherscan (Verified)**: [🔗 View on Sepolia Etherscan](https://sepolia.etherscan.io/address/0x9c0A50af3C04B8bFE15B0161270a3E95115FdE3D#code)  

---

## 📜 License  

This project is licensed under the **MIT License**.  
See [LICENSE](LICENSE) for details.  
