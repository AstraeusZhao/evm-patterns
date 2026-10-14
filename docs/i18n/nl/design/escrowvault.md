# EscrowVault

ETH-escrow met drie partijen: de storter financiert, de bemiddelaar betaalt de begunstigde of betaalt de storter terug. Beide handelspartijen kunnen een geschil openen en de middelen blokkeren.

## Rollen

- **Storter:** financiert de escrow en kan een geschil openen.
- **Begunstigde:** ontvangt de uitbetaling en kan een geschil openen.
- **Bemiddelaar:** vertrouwde derde voor uitbetaling, terugbetaling en geschillenbeslechting.

## Toestandsmachine

```
Active --release()--> Released
Active --refund()--> Refunded
Active --raiseDispute()--> Disputed --resolveDispute(bool)--> Released / Refunded
```

`inState` bewaakt iedere statuswijziging en staat alleen deze overgangen toe.

## Beveiliging

- Rollen beperken iedere handeling tot de aangewezen deelnemers.
- CEI: de status verandert vóór een ETH-overdracht.
- `nonReentrant` beschermt de betaalpaden.
- `receive()` breekt af. Alleen expliciete stortingen tellen mee in het geboekte saldo; `release` en `refund` versturen het bijbehorende escrowbedrag. Gedwongen stortingen veranderen deze boekhouding niet.

## Vertrouwensaannamen

De bemiddelaar wordt volledig vertrouwd: in `Active` kan deze altijd uitbetalen of terugbetalen en beslist deze over geschillen. Productiesystemen vervangen één bemiddelaar vaak door een multisig of een arbitragemarkt.
