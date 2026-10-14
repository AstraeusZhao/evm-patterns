# EnglishAuction

Eine Auktion mit steigenden Geboten. Die ursprünglichen Entwurfsnotizen beschreiben sofortige Rückzahlungen an überbotene Teilnehmer.

## Eigenschaften

- Ein Gebot muss das bisherige Höchstgebot strikt übersteigen.
- Die ursprünglichen Notizen beschreiben eine Rückzahlung beim Überbieten unter Beachtung von Checks-Effects-Interactions (CEI).
- Der Verkäufer kann das Höchstgebot erst nach Auktionsende abheben.

## Vertrauensannahmen

Der Verkäufer muss den Gegenstand nach Auktionsende ausserhalb der Blockchain liefern. Für den aktuellen Rückzahlungsablauf ist der Quellcode massgeblich.
