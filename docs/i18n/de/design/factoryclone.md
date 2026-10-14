# FactoryClone

Fabrik für die Bereitstellung minimaler EIP-1167-Proxyklone mittels CREATE2.

## Eigenschaften

- Der Laufzeitbytecode verwendet den standardisierten minimalen Proxy mit 45 Byte.
- Jeder Salt ergibt eine deterministische Klonadresse.
- Alle Klone teilen dieselbe unveränderliche Implementierung.

## Vertrauensannahmen

Die Klone teilen Code, besitzen jedoch jeweils eigenen Speicher. Die Implementierung darf den Zustand verschiedener Klone nicht fälschlich in gemeinsamem Speicher ablegen.
