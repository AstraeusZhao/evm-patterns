# BondingCurve

Doorlopende tokenuitgifte met `price = supply` en een reserve van `reserve = supply^2 / 2`.

## Eigenschappen

- Kopen mint tokens tegen stijgende marginale prijzen; vroege kopers betalen minder.
- Verkopen verbrandt tokens en betaalt het bijbehorende reservedeel terug. Bij monotoon stijgende prijzen ligt de teruggave onder het eerder betaalde bedrag.
- Gehele afronding van de vierkantswortel behoudt `supply^2 >= 2 * reserve`.

## Vertrouwensaannamen

Er is geen eigenaar; na implementatie werkt de curve zelfstandig.
