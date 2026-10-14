# SafeERC20Wrapper

Bibliothek für sichere Tokenübertragungen, auch für Token ohne Rückgabedaten.

## Eigenschaften

- Prüft den Erfolg mit einem Low-Level-`call` und `abi.decode`. Ein optionaler boolescher Rückgabewert muss `true` sein.
- Unterstützt Token nach Art von USDT, die keine Daten zurückgeben.

## Vertrauensannahmen

Der Tokenvertrag muss seine Bestände korrekt verwalten.
