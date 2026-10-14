# AMM

## Reikwijdte

Bij [`src/AMM/AMM.sol`](../../src/AMM/AMM.sol). Dit contract demonstreert virtuele reserves met een constant product. Het bewaart of verstuurt geen activa.

## Gedrag

- `addLiquidity` verhoogt de twee openbare reservewaarden.
- `swapAForB` en `swapBForA` berekenen de uitvoer als `amountIn * reserveOut / (reserveIn + amountIn)` en werken de virtuele reserves bij.
- `priceA` geeft de verhouding tussen reserves met een precisie van `1e18`.

## Aannamen en beperkingen

- Reserves zijn boekhoudkundige waarden van de aanroeper, geen tokensaldi. Iedereen kan ze zonder storting verhogen.
- Een wissel int geen invoertokens en levert geen uitvoertokens. Gebeurtenissen en retourwaarden bewijzen dus geen afgewikkelde transactie.
- LP-aandelen, kosten, minimale uitvoer, deadlines en orakelbescherming ontbreken. `priceA` is een momentopname en geen geschikt prijsorakel.
- Scheve reserves of kleine invoer kunnen nul uitvoer opleveren. Solidity breekt bij rekenkundige overflow af.

Dit is een rekendemonstratie, geen beurs of AMM voor het bewaren van echte middelen.

## Testbewijs

Bij bronrevisie `c4ebe5c` was de gemeten regeldekking 0%. De regressietest stuurt ETH naar de niet-betaalbare `addLiquidity` en bevestigt alleen dat de aanroep vóór de functie-inhoud mislukt. Reserves en wisselformules worden daarmee niet getest. Zie het [dekkingsrapport](../reports/AUDIT_COVERAGE.md).
