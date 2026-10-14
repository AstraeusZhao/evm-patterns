# StakingVault

Stakingkluis die hoofdsom bijhoudt en beloningen lineair over de tijd berekent.

## Eigenschappen

- Beloningen groeien volgens `elapsed * stakedAmount * rewardRatePerSecond`.
- Opnamen verminderen de hoofdsom; beloningen worden apart opgehaald.
- CEI en een herintredingsslot beschermen de uitbetalingen.

## Vertrouwensaannamen

De oorspronkelijke ontwerpnotities beschrijven het instellen van de beloningsvoet voor een demonstratie. Voor huidige bevoegdheden en financieringsvoorwaarden is de broncode bepalend.
