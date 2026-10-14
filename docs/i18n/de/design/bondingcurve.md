# BondingCurve

Kontinuierliche Tokenausgabe mit `price = supply` und einer Reserve von `reserve = supply^2 / 2`.

## Eigenschaften

- Käufe prägen Token zu steigenden Grenzpreisen; frühe Käufer zahlen weniger.
- Verkäufe verbrennen Token und erstatten den entsprechenden Reserveanteil. Bei monoton steigenden Preisen liegt die Erstattung unter dem zuvor gezahlten Betrag.
- Die ganzzahlige Rundung der Quadratwurzel erhält `supply^2 >= 2 * reserve`.

## Vertrauensannahmen

Es gibt keinen Eigentümer; die Kurve arbeitet nach der Bereitstellung selbstständig.
