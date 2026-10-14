# UUPSProxy

Proxy mit Implementierungsadresse in einem eigenen EIP-1967-Slot und Upgrades ausschliesslich durch den Eigentümer.

## Eigenschaften

- Aufrufe werden an die im EIP-1967-Slot gespeicherte Implementierung delegiert.
- Upgrades erhalten den Proxyspeicher und damit den Zustand.
- Die Implementierungsadresse muss Code enthalten, damit der Proxy funktionsfähig bleibt.

## Vertrauensannahmen

Ein einzelner Eigentümer kontrolliert Upgrades. Produktive Systeme verwenden dafür häufig eine Zeitsperre oder Multisignatur.
