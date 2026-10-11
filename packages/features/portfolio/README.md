# Portfolio package

Shared portfolio positions and client cash/balance response DTOs for OMS
broker-house apps. The package depends on `market` for the market security
model embedded in position responses. Existing JSON mapping is preserved.

Benemoy keeps compatibility exports at its old response model paths. Portfolio
controllers, repositories, calculations, and UI remain in the app for now.

```dart
import 'package:portfolio/portfolio.dart';
```
