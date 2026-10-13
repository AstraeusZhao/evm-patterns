# Contract Index

This index maps each tracked Solidity source file to its test references and
design note, where present. A link to `AuditRegression.t.sol` means that file
contains a regression case touching the example; it does not imply complete
coverage. `-` means there is no dedicated test or design note in the current
tree. The [coverage baseline](reports/AUDIT_COVERAGE.md) records measured
coverage and known limitations.

## Access Control and Value Flows

| Pattern | Demonstrates | Tests | Design |
| --- | --- | --- | --- |
| [Counter](../src/Counter/Counter.sol) | Basic state changes, arithmetic, and events. | - | - |
| [Ownable](../src/Ownable/Ownable.sol) | Single-owner checks, ownership transfer, and renunciation. | [Ownable](../test/Ownable/Ownable.t.sol) | [Ownable](design/ownable.md) |
| [Pausable](../src/Pausable/Pausable.sol) | Owner-controlled emergency pause state. | [Pausable](../test/Pausable/Pausable.t.sol) | [Pausable](design/pausable.md) |
| [MultiSigWallet](../src/MultiSigWallet/MultiSigWallet.sol) | Threshold approvals and authorized transaction execution. | [MultiSigWallet](../test/MultiSigWallet/MultiSigWallet.t.sol), [regression](../test/AuditRegression.t.sol) | [MultiSigWallet](design/multisigwallet.md) |
| [TimelockController](../src/TimelockController/TimelockController.sol) | Delayed role-based operations and predecessor state. | [TimelockController](../test/TimelockController/TimelockController.t.sol), [regression](../test/AuditRegression.t.sol) | [TimelockController](design/timelockcontroller.md) |
| [EscrowVault](../src/EscrowVault/EscrowVault.sol) | Three-party escrow roles, state transitions, and dispute resolution. | [EscrowVault](../test/EscrowVault/EscrowVault.t.sol) | [EscrowVault](design/escrowvault.md) |
| [PullPayment](../src/PullPayment/PullPayment.sol) | Deferred recipient withdrawals. | [PullPayment](../test/PullPayment/PullPayment.t.sol) | [PullPayment](design/pullpayment.md) |
| [PullPaymentVault](../src/PullPaymentVault/PullPaymentVault.sol) | User-owned ETH credits, pausing, and checks-effects-interactions. | [PullPaymentVault](../test/PullPaymentVault/PullPaymentVault.t.sol) | [PullPaymentVault](design/pull-payment-vault.md) |
| [StakingVault](../src/StakingVault/StakingVault.sol) | Staking balances and funded, time-based rewards. | [StakingVault](../test/StakingVault/StakingVault.t.sol), [regression](../test/AuditRegression.t.sol) | [StakingVault](design/stakingvault.md) |
| [Crowdfunding](../src/Crowdfunding/Crowdfunding.sol) | Campaign deadlines, pledges, and pull-based refunds. | - | - |
| [Whitelist](../src/Whitelist/Whitelist.sol) | Allowlist checks and a gated ETH sale. | [Whitelist](../test/Whitelist/Whitelist.t.sol) | [Whitelist](design/whitelist.md) |

## Tokens and NFTs

| Pattern | Demonstrates | Tests | Design |
| --- | --- | --- | --- |
| [ERC20Token](../src/ERC20Token/ERC20Token.sol) | ERC-20 balances, allowances, minting, and transfers. | [ERC20Token](../test/ERC20Token/ERC20Token.t.sol), [regression](../test/AuditRegression.t.sol) | [ERC20Token](design/erc20token.md) |
| [ERC20Permit](../src/ERC20Permit/ERC20Permit.sol) | EIP-2612 approvals with typed signatures. | [regression](../test/AuditRegression.t.sol) | - |
| [ERC721NFT](../src/ERC721NFT/ERC721NFT.sol) | NFT ownership, approvals, and safe transfers. | [ERC721NFT](../test/ERC721NFT/ERC721NFT.t.sol), [regression](../test/AuditRegression.t.sol) | [ERC721NFT](design/erc721nft.md) |
| [ERC1155](../src/ERC1155/ERC1155.sol) | Multi-token balances and receiver checks. | [regression](../test/AuditRegression.t.sol) | - |
| [BatchMint](../src/BatchMint/BatchMint.sol) | Batched mint and transfer operations. | [regression](../test/AuditRegression.t.sol) | - |
| [Royalty](../src/Royalty/Royalty.sol) | EIP-2981 royalty queries and ERC-165 support. | [regression](../test/AuditRegression.t.sol) | - |
| [NFTMarketplace](../src/NFTMarketplace/NFTMarketplace.sol) | Fixed-price listings and NFT delivery with payment splitting. | [regression](../test/AuditRegression.t.sol) | - |
| [MerkleAirdrop](../src/MerkleAirdrop/MerkleAirdrop.sol) | Merkle-proof claims and duplicate-claim protection. | [MerkleAirdrop](../test/MerkleAirdrop/MerkleAirdrop.t.sol) | [MerkleAirdrop](design/merkleairdrop.md) |
| [GovernanceToken](../src/GovernanceToken/GovernanceToken.sol) | Delegated voting power with checkpoints. | [regression](../test/AuditRegression.t.sol) (overflow guard only) | - |
| [VestingWallet](../src/VestingWallet/VestingWallet.sol) | Linear ERC-20 vesting and beneficiary releases. | [regression](../test/AuditRegression.t.sol) (failed-transfer case only) | - |

## Signatures, Calls, and Deployment

| Pattern | Demonstrates | Tests | Design |
| --- | --- | --- | --- |
| [EIP712](../src/EIP712/EIP712.sol) | Domain-separated typed-data hashing and signature recovery. | [regression](../test/AuditRegression.t.sol) | - |
| [SignatureReplay](../src/SignatureReplay/SignatureReplay.sol) | Nonces, deadlines, and ECDSA malleability checks. | [SignatureReplay](../test/SignatureReplay/SignatureReplay.t.sol) | [SignatureReplay](design/signaturereplay.md) |
| [SafeERC20Wrapper](../src/SafeERC20Wrapper/SafeERC20Wrapper.sol) | Handling tokens with missing or false return values. | [SafeERC20Wrapper](../test/SafeERC20Wrapper/SafeERC20Wrapper.t.sol), [regression](../test/AuditRegression.t.sol) | [SafeERC20Wrapper](design/safeerc20wrapper.md) |
| [Multicall](../src/Multicall/Multicall.sol) | Atomic batched delegatecalls in the caller's storage context. | [Multicall](../test/Multicall/Multicall.t.sol), [regression](../test/AuditRegression.t.sol) | [Multicall](design/multicall.md) |
| [FactoryClone](../src/FactoryClone/FactoryClone.sol) | EIP-1167 clones deployed with CREATE2. | [FactoryClone](../test/FactoryClone/FactoryClone.t.sol), [regression](../test/AuditRegression.t.sol) | [FactoryClone](design/factoryclone.md) |
| [UUPSProxy](../src/UUPSProxy/UUPSProxy.sol) | EIP-1967 proxy storage and owner-controlled upgrades. | [UUPSProxy](../test/UUPSProxy/UUPSProxy.t.sol), [regression](../test/AuditRegression.t.sol) | [UUPSProxy](design/uupsproxy.md) |
| [FlashLoanReceiver](../src/FlashLoanReceiver/FlashLoanReceiver.sol) | An owner-triggered ERC-3156-style receiver for one configured lender. | [regression](../test/AuditRegression.t.sol) (untrusted callback only) | [FlashLoanReceiver](design/flashloanreceiver.md) |

## Markets and Pricing

| Pattern | Demonstrates | Tests | Design |
| --- | --- | --- | --- |
| [AMM](../src/AMM/AMM.sol) | Virtual constant-product swap arithmetic; no token custody or settlement. | - | [AMM](design/amm.md) |
| [BondingCurve](../src/BondingCurve/BondingCurve.sol) | Token issuance along a quadratic price curve. | [BondingCurve](../test/BondingCurve/BondingCurve.t.sol) | [BondingCurve](design/bondingcurve.md) |
| [DutchAuction](../src/DutchAuction/DutchAuction.sol) | Descending price and first-accept settlement. | [DutchAuction](../test/DutchAuction/DutchAuction.t.sol) | [DutchAuction](design/dutchauction.md) |
| [EnglishAuction](../src/EnglishAuction/EnglishAuction.sol) | Ascending bids and pull-based refunds. | [EnglishAuction](../test/EnglishAuction/EnglishAuction.t.sol), [regression](../test/AuditRegression.t.sol) | [EnglishAuction](design/englishauction.md) |
| [PriceOracle](../src/PriceOracle/PriceOracle.sol) | Admin-posted prices with staleness checks. | [PriceOracle](../test/PriceOracle/PriceOracle.t.sol), [regression](../test/AuditRegression.t.sol) | [PriceOracle](design/priceoracle.md) |

## Security Demonstrations

| Pattern | Demonstrates | Tests | Design |
| --- | --- | --- | --- |
| [ReentrancyGuard](../src/ReentrancyGuard/ReentrancyGuard.sol) | A state lock and a re-entry attack demonstration. | [ReentrancyGuard](../test/ReentrancyGuard/ReentrancyGuard.t.sol) | [ReentrancyGuard](design/reentrancyguard.md) |
| [BlockTimestamp](../src/BlockTimestamp/BlockTimestamp.sol) | Timestamp influence and miner/validator discretion. | - | - |
| [FrontRunning](../src/FrontRunning/FrontRunning.sol) | Sender- and chain-bound commit/reveal. | [regression](../test/AuditRegression.t.sol) | - |
| [Randomness](../src/Randomness/Randomness.sol) | Why block-derived values are unsafe for valuable randomness. | - | - |
| [SelfDestructDemo](../src/SelfDestructDemo/SelfDestructDemo.sol) | `selfdestruct` behavior under EIP-6780. | - | - |
| [StorageCollision](../src/StorageCollision/StorageCollision.sol) | Proxy state collision and a fixed-slot comparison. | [StorageCollision](../test/StorageCollision/StorageCollision.t.sol) | [StorageCollision](design/storagecollision.md) |
| [TxOriginAuth](../src/TxOriginAuth/TxOriginAuth.sol) | The authorization risk of checking `tx.origin`. | - | - |
| [UncheckedCall](../src/UncheckedCall/UncheckedCall.sol) | Failure handling for low-level call return values. | - | - |

## Reading the Test References

Dedicated suites live under `test/<Pattern>/`. Cross-cutting fixes and checks
may instead appear in `test/AuditRegression.t.sol`. A test reference identifies
where to look; it does not state that all branches or security properties have
been exercised. Review the [coverage report](reports/AUDIT_COVERAGE.md) and the
contract's own limitations before relying on an example.
