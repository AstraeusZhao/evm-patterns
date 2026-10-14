# MultiSigWallet

Wallet met meerdere eigenaars die transacties pas uitvoert na voldoende bevestigingen.

## Interfaces

- `submitTransaction(to, value, data)`: een eigenaar stelt een aanroep voor; de eerste bevestiging wordt automatisch vastgelegd.
- `confirmTransaction(txId)` / `revokeConfirmation(txId)`: vóór uitvoering bevestigingen toevoegen of intrekken.
- `executeTransaction(txId)`: uitvoeren na het bereiken van de drempel; iedere transactie kan slechts eenmaal worden uitgevoerd.
- `addOwner` / `removeOwner` / `replaceOwner` / `changeRequired`: eigenaars en drempel beheren. Bij verwijderen wordt de drempel aangepast zodat de wallet bestuurbaar blijft.

## Beveiliging

- `onlyOwner` beperkt statuswijzigingen.
- CEI: `executed` wordt vóór de externe aanroep gezet, zodat herintreding ziet dat de transactie al is uitgevoerd.
- `nonReentrant` biedt een tweede beschermingslaag voor uitvoering.
- Na verwijderen geldt `required <= owners.length`.

## Vertrouwensaannamen

De eigenaars bepalen de groep en drempel. Een overgenomen meerderheid kan de middelen wegnemen. Daglimieten en een toestemmingslijst voor aanroepdoelen ontbreken; productiewallets voegen zulke grenzen vaak toe.

## Wijzigingsnotitie 2025-11

De oorspronkelijke notities vermelden een controle van de logica. Dit is geen onafhankelijke veiligheidscertificering.
