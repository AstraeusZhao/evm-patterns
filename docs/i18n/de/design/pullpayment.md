# PullPayment

Auszahlung durch aktive Abhebung: Eingehende ETH werden als Guthaben verbucht; Empfänger wählen den Abhebungszeitpunkt selbst.

## Eigenschaften

- `receive` schreibt dem Sender Guthaben gut, ohne eine ausgehende Übertragung zu erzwingen.
- Abhebungen folgen CEI und verringern das Guthaben vor dem externen Aufruf.
- Eine Wiedereintrittssperre schützt den Abhebungspfad.

## Vertrauensannahmen

Guthaben entsteht nur durch eingegangene ETH. Es gibt keinen Pfad für ungedeckte Gutschriften.
