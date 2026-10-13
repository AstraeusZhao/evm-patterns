# Audit coverage baseline

Source baseline: `c4ebe5c` (2026-10-12). Command: `forge coverage --report summary`, Foundry v1.8.1, solc 0.8.24. The suite at that baseline passed 132 tests; a directory name does not establish complete behavioral coverage. The following measured percentages include coverage limitations in assembly and compiler mapping; Foundry reported some source anchors it could not map. A passing suite is not a security audit certification. This report does not measure the later workflow-only change at `ee98f15`.

| File | Lines | Statements | Branches | Functions |
|---|---|---|---|---|
| src/AMM/AMM.sol                                  | 0.00% (0/21)      | 0.00% (0/23)      | 0.00% (0/5)     | 0.00% (0/4)      |
| src/BatchMint/BatchMint.sol                      | 57.89% (11/19)    | 45.45% (10/22)    | 30.00% (3/10)   | 100.00% (3/3)    |
| src/BlockTimestamp/BlockTimestamp.sol            | 0.00% (0/4)       | 0.00% (0/4)       | N/A (0/0)       | 0.00% (0/1)      |
| src/BondingCurve/BondingCurve.sol                | 100.00% (39/39)   | 88.89% (40/45)    | 50.00% (5/10)   | 100.00% (8/8)    |
| src/Counter/Counter.sol                          | 0.00% (0/8)       | 0.00% (0/5)       | N/A (0/0)       | 0.00% (0/3)      |
| src/Crowdfunding/Crowdfunding.sol                | 0.00% (0/27)      | 0.00% (0/34)      | 0.00% (0/10)    | 0.00% (0/4)      |
| src/DutchAuction/DutchAuction.sol                | 96.55% (28/29)    | 82.50% (33/40)    | 30.00% (3/10)   | 100.00% (4/4)    |
| src/EIP712/EIP712.sol                            | 58.33% (7/12)     | 47.62% (10/21)    | 25.00% (1/4)    | 100.00% (2/2)    |
| src/ERC1155/ERC1155.sol                          | 54.55% (12/22)    | 40.00% (26/65)    | 17.65% (3/17)   | 46.15% (6/13)    |
| src/ERC20Permit/ERC20Permit.sol                  | 25.00% (9/36)     | 30.00% (12/40)    | 16.67% (1/6)    | 28.57% (2/7)     |
| src/ERC20Token/ERC20Token.sol                    | 100.00% (43/43)   | 83.72% (36/43)    | 30.00% (3/10)   | 100.00% (9/9)    |
| src/ERC721NFT/ERC721NFT.sol                      | 93.44% (57/61)    | 77.61% (52/67)    | 26.67% (4/15)   | 88.89% (16/18)   |
| src/EnglishAuction/EnglishAuction.sol            | 96.43% (27/28)    | 85.29% (29/34)    | 44.44% (4/9)    | 100.00% (5/5)    |
| src/EscrowVault/EscrowVault.sol                  | 89.83% (53/59)    | 77.61% (52/67)    | 23.53% (4/17)   | 85.71% (12/14)   |
| src/FactoryClone/FactoryClone.sol                | 100.00% (15/15)   | 100.00% (15/15)   | 100.00% (2/2)   | 100.00% (3/3)    |
| src/FlashLoanReceiver/FlashLoanReceiver.sol      | 17.65% (3/17)     | 12.82% (5/39)     | 16.67% (2/12)   | 40.00% (2/5)     |
| src/FrontRunning/FrontRunning.sol                | 100.00% (9/9)     | 75.00% (15/20)    | 25.00% (2/8)    | 100.00% (4/4)    |
| src/GovernanceToken/GovernanceToken.sol          | 16.22% (6/37)     | 11.11% (4/36)     | 9.09% (1/11)    | 28.57% (2/7)     |
| src/MerkleAirdrop/MerkleAirdrop.sol              | 73.08% (19/26)    | 64.71% (22/34)    | 28.57% (2/7)    | 60.00% (3/5)     |
| src/MultiSigWallet/MultiSigWallet.sol            | 92.23% (95/103)   | 83.48% (96/115)   | 30.77% (8/26)   | 90.00% (18/20)   |
| src/Multicall/Multicall.sol                      | 100.00% (6/6)     | 100.00% (9/9)     | 100.00% (1/1)   | 100.00% (1/1)    |
| src/NFTMarketplace/NFTMarketplace.sol            | 85.71% (18/21)    | 76.36% (42/55)    | 35.71% (5/14)   | 83.33% (5/6)     |
| src/Ownable/Ownable.sol                          | 100.00% (13/13)   | 83.33% (10/12)    | 33.33% (1/3)    | 100.00% (4/4)    |
| src/Pausable/Pausable.sol                        | 100.00% (14/14)   | 90.00% (9/10)     | 66.67% (2/3)    | 100.00% (6/6)    |
| src/PriceOracle/PriceOracle.sol                  | 100.00% (12/12)   | 100.00% (14/14)   | 100.00% (4/4)   | 100.00% (3/3)    |
| src/PullPayment/PullPayment.sol                  | 100.00% (18/18)   | 85.00% (17/20)    | 40.00% (2/5)    | 100.00% (4/4)    |
| src/PullPaymentVault/PullPaymentVault.sol        | 73.81% (31/42)    | 60.00% (24/40)    | 9.09% (1/11)    | 72.73% (8/11)    |
| src/Randomness/Randomness.sol                    | 0.00% (0/9)       | 0.00% (0/7)       | N/A (0/0)       | 0.00% (0/3)      |
| src/ReentrancyGuard/ReentrancyGuard.sol          | 100.00% (4/4)     | 100.00% (4/4)     | 100.00% (1/1)   | 100.00% (1/1)    |
| src/Royalty/Royalty.sol                          | 42.86% (6/14)     | 46.67% (7/15)     | 0.00% (0/4)     | 50.00% (2/4)     |
| src/SafeERC20Wrapper/SafeERC20Wrapper.sol        | 100.00% (18/18)   | 94.74% (18/19)    | 66.67% (2/3)    | 100.00% (7/7)    |
| src/SelfDestructDemo/SelfDestructDemo.sol        | 0.00% (0/6)       | 0.00% (0/4)       | 0.00% (0/1)     | 0.00% (0/3)      |
| src/SignatureReplay/SignatureReplay.sol          | 100.00% (21/21)   | 86.67% (26/30)    | 42.86% (3/7)    | 100.00% (3/3)    |
| src/StakingVault/StakingVault.sol                | 100.00% (31/31)   | 89.74% (70/78)    | 35.71% (5/14)   | 100.00% (11/11)  |
| src/StorageCollision/StorageCollision.sol        | 90.48% (19/21)    | 73.68% (14/19)    | 0.00% (0/2)     | 87.50% (7/8)     |
| src/TimelockController/TimelockController.sol    | 97.40% (75/77)    | 87.13% (88/101)   | 57.14% (12/21)  | 94.12% (16/17)   |
| src/TxOriginAuth/TxOriginAuth.sol                | 0.00% (0/7)       | 0.00% (0/6)       | 0.00% (0/3)     | 0.00% (0/3)      |
| src/UUPSProxy/UUPSProxy.sol                      | 100.00% (20/20)   | 85.71% (18/21)    | 66.67% (2/3)    | 100.00% (6/6)    |
| src/UncheckedCall/UncheckedCall.sol              | 0.00% (0/10)      | 0.00% (0/9)       | 0.00% (0/3)     | 0.00% (0/3)      |
| src/VestingWallet/VestingWallet.sol              | 90.48% (19/21)    | 80.00% (28/35)    | 20.00% (1/5)    | 66.67% (2/3)     |
| src/Whitelist/Whitelist.sol                      | 79.41% (27/34)    | 66.67% (22/33)    | 27.27% (3/11)   | 70.00% (7/10)    |
| Total                                            | 76.58% (847/1106) | 67.40% (920/1365) | 30.57% (96/314) | 75.87% (217/286) |

This library includes intentionally vulnerable educational examples (e.g. tx.origin, randomness and unchecked calls). Those examples retain their warning and scope rather than being presented as production-safe implementations.
