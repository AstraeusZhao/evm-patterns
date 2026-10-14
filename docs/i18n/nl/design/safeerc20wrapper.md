# SafeERC20Wrapper

Bibliotheek voor veilige tokenoverdrachten, ook voor tokens zonder retourgegevens.

## Eigenschappen

- Controleert succes via een low-level `call` en `abi.decode`. Een optionele booleaanse retourwaarde moet `true` zijn.
- Ondersteunt tokens in USDT-stijl die geen gegevens retourneren.

## Vertrouwensaannamen

Het tokencontract moet zelf correcte saldi bijhouden.
