# FlashLoanReceiver

## Reikwijdte

Bij [`src/FlashLoanReceiver/FlashLoanReceiver.sol`](../../src/FlashLoanReceiver/FlashLoanReceiver.sol). Een educatieve ontvanger met één vaste kredietverstrekker in ERC-3156-stijl.

## Gedrag

- De implementerende partij wordt eigenaar. De constructor controleert of het adres van de kredietverstrekker code bevat en slaat het op.
- Alleen de eigenaar kan `borrow` aanroepen. Verwacht token, bedrag en maximale vergoeding worden vóór de kredietaanroep opgeslagen.
- `onFlashLoan` accepteert alleen de vaste kredietverstrekker en controleert actieve lening, initiatiefnemer, token, bedrag, kostenlimiet en terugbetalingssaldo.
- De callback geeft toestemming voor `amount + fee` en retourneert de ERC-3156-callbackhash. Na succesvolle terugkeer wist `borrow` de leningstatus en trekt het de tokentoestemming in.
- De eigenaar kan tokens terughalen wanneer geen lening actief is.

## Beveiliging

- Een willekeurige aanroeper kan zich bij de callback niet voordoen als de kredietverstrekker.
- Callbackparameters moeten overeenkomen met de lening uit `borrow`.
- Vóór toestemming moet het saldo hoofdsom en vergoeding dekken.
- `active` blokkeert opnieuw lenen en tokens terughalen tijdens een lening.

## Aannamen en beperkingen

- De vaste kredietverstrekker wordt vertrouwd. Aanwezige code bewijst geen ERC-3156-conformiteit of correct gedrag.
- Een strategiehaak ontbreekt. `data` wordt genegeerd en geleende middelen worden vóór terugbetaling niet gebruikt.
- Kredietverstrekker en token moeten terugbetaling via toestemming ondersteunen. Transferkosten, rebasing, kwaadwillende of afwijkende tokens kunnen saldoaannamen doorbreken.
- De eigenaar bepaalt wanneer wordt geleend en kan ongebruikte tokens terughalen. Wisselen van kredietverstrekker en governance ontbreken.
- Dit is een leervoorbeeld, geen onafhankelijk gecontroleerde integratie voor productiemiddelen.

## Testbewijs

Een afzonderlijke testsuite ontbreekt. Bij bronrevisie `c4ebe5c` controleert `test/AuditRegression.t.sol` de afwijzing van een onbetrouwbare callbackaanroeper; de gemeten regeldekking is 17,65%. Andere callbacks en interacties met de kredietverstrekker zijn daarmee niet aangetoond. Zie het [dekkingsrapport](../reports/AUDIT_COVERAGE.md).
