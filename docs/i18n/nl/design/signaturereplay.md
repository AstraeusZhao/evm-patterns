# SignatureReplay

Voorkomt hergebruik van EIP-712-handtekeningen voor claims met een nonce per account.

## Eigenschappen

- De hash gebruikt domeinscheiding en getypeerde gegevens.
- `ecrecover` bepaalt de ondertekenaar, die gelijk moet zijn aan de ingestelde ondertekenaar.
- Iedere geslaagde claim verhoogt de accountnonce en maakt oude handtekeningen ongeldig.
- Een deadlinecontrole beperkt de geldigheid.

## Vertrouwensaannamen

De ondertekeningssleutel moet veilig buiten de blockchain worden bewaard. Bij uitlekken kunnen aanvallers claims namens accounts autoriseren.
