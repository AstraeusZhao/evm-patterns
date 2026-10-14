# PullPaymentVault

`PullPaymentVault` is een van de vroege uitvoerbare patronen in de repository. Een kleine boekhoudkluis demonstreert veilige opnamegrenzen zonder externe afhankelijkheden.

## Gedrag

- Iedereen kan ETH storten en krijgt intern tegoed.
- Gebruikers kunnen alleen hun eigen geregistreerde tegoed opnemen.
- De eigenaar kan stortingen en opnamen pauzeren en hervatten.
- Eigendom kan worden overgedragen; de eigenaar heeft geen beheerpad om geld op te nemen.

## Beveiliging

- Het tegoed wordt gecontroleerd voordat het daalt.
- CEI: het tegoed daalt vóór de aanroep van de ontvanger.
- Een herintredingsslot voorkomt opnieuw `withdraw` tijdens een ETH-overdracht.
- Aangepaste fouten maken foutpaden expliciet zonder foutstrings.
- Een pauze stopt handelingen maar biedt geen herstel. Gebruikers moeten op hervatting door de eigenaar wachten om op te nemen.

## Aannamen en beperkingen

- De eigenaar wordt vertrouwd met pauzes en eigendomsoverdracht.
- Weigert de ontvanger ETH, dan mislukt de overdracht en wordt de opname teruggedraaid; het tegoed blijft behouden.
- Upgrades, kosten, tokenondersteuning en noodopnames ontbreken.
- Dit voorbeeld dient leren en beoordeling, heeft geen onafhankelijke beveiligingsaudit en is niet bedoeld om productiemiddelen te bewaren.

## Testdekking

Foundry-tests behandelen gewone stortingen en opnamen, pauzes door de eigenaar, storten tijdens een pauze en bescherming tegen te hoge opnamen.
