# Quantum Cats — real wallet + minting build

This package converts the supplied front-end demo into a real ERC-721 minting dapp. The original file explicitly said it had no working wallet or minting; this build adds a real wallet connection and a Solidity contract. fileciteturn0file0L338-L347

## What is included
- `contracts/QuantumCats.sol` — ERC-721 contract using OpenZeppelin Contracts 5.x.
- `frontend/index.html` — wallet connection, chain switching, mint transaction, live supply/price, balance check and transaction status.

## Important deployment limitation
I cannot deploy a real mainnet contract from this chat because that requires control of a deployer wallet and payment of network gas. **Do not send me your seed phrase/private key.** Deploy it yourself through Remix or your own secure deployment environment.

## Deploy with Remix
1. Open Remix and create `QuantumCats.sol`.
2. Install/import OpenZeppelin Contracts 5.x dependencies.
3. Compile with Solidity `0.8.24` or compatible 0.8.x compiler.
4. Deploy using your own wallet. Constructor values:
   - `initialOwner`: your wallet address
   - `priceWei`: mint price in wei. Example: 0.01 ETH = `10000000000000000`
   - `walletLimit`: e.g. `5`
   - `baseURI`: URL ending in a path, e.g. `ipfs://YOUR_CID/`
   - `unrevealedURI`: metadata URI shown before reveal
   - `royaltyReceiver`: your royalty recipient
   - `royaltyBps`: e.g. `500` = 5%
5. Verify the deployed contract on the block explorer.
6. Put the deployed address into `CONFIG.contractAddress` in `frontend/index.html`.
7. Set `CONFIG.chainId` and `CONFIG.chainName` to the network you actually deployed on.
8. Host `frontend/index.html` on HTTPS.

## Security
- Never ask users for seed phrases/private keys.
- Test on a public testnet before accepting real funds.
- Have the contract independently reviewed/audited before a public mainnet mint.
- The contract uses OpenZeppelin ERC-721, pausable and royalty components. OpenZeppelin documents ERC-721 and these extensions in its current Contracts 5.x documentation. https://docs.openzeppelin.com/contracts/5.x/api/token/erc721
- This build does **not** claim to obtain actual quantum-computer randomness. If you want provable quantum randomness, an actual randomness oracle/hardware integration must be added and independently verified.
