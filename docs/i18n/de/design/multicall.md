# Multicall

Bündelt mehrere Selbstaufrufe in einer Transaktion.

## Eigenschaften

- `delegatecall` erhält `msg.sender` und den Speicherkontext.
- Scheitert ein Aufruf, wird das gesamte Bündel atomar zurückgesetzt.

## Vertrauensannahmen

Der aufgerufene Code muss vertrauenswürdig sein, da er über `delegatecall` den Speicher des aktuellen Vertrags verwendet.
