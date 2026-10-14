# StakingVault

Staking-Tresor, der Kapital erfasst und zeitabhängige Belohnungen linear berechnet.

## Eigenschaften

- Belohnungen entstehen nach `elapsed * stakedAmount * rewardRatePerSecond`.
- Abhebungen reduzieren das Kapital; Belohnungen werden separat abgerufen.
- CEI und eine Wiedereintrittssperre schützen Auszahlungen.

## Vertrauensannahmen

Die ursprünglichen Entwurfsnotizen beschreiben eine demonstrative Festlegung der Belohnungsrate. Für aktuelle Berechtigungen und Anforderungen an die Finanzierung ist der Quellcode massgeblich.
