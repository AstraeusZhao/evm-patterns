# EscrowVault

ETH-Escrow mit drei Parteien: Der Einzahler stellt Mittel bereit, der Treuhänder zahlt an den Begünstigten aus oder erstattet dem Einzahler. Beide Handelsparteien können einen Streit auslösen und die Mittel sperren.

## Rollen

- **Einzahler:** finanziert den Escrow und kann einen Streit melden.
- **Begünstigter:** erhält die Auszahlung und kann einen Streit melden.
- **Treuhänder:** vertrauenswürdiger Dritter für Auszahlung, Erstattung und Streitentscheidung.

## Zustandsautomat

```
Active --release()--> Released
Active --refund()--> Refunded
Active --raiseDispute()--> Disputed --resolveDispute(bool)--> Released / Refunded
```

`inState` schützt jede Zustandsänderung und erlaubt nur diese Übergänge.

## Sicherheitseigenschaften

- Rollen beschränken jede Aktion auf die vorgesehenen Teilnehmer.
- CEI: Der Zustand wird vor einer ETH-Übertragung geändert.
- `nonReentrant` schützt die Auszahlungspfade.
- `receive()` bricht ab. Nur explizite Einzahlungen des Einzahlers zählen zum gebuchten Bestand; `release` und `refund` übertragen den entsprechenden Escrowbetrag. Erzwungene Einzahlungen verändern diese Buchung nicht.

## Vertrauensannahmen

Dem Treuhänder wird vollständig vertraut: In `Active` kann er jederzeit auszahlen oder erstatten und entscheidet Streitfälle. Produktive Systeme ersetzen einen einzelnen Treuhänder häufig durch eine Multisignatur oder einen Schlichtungsmarkt.
