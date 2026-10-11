# Auth package

Shared authentication data contracts for OMS broker-house apps. The package
owns the transport-neutral `LoginRequest` DTO and the `UserProfile` response
model, including its token and user-detail payloads and JSON mapping.

The Benemoy app keeps compatibility exports at the existing model import paths.
Its authentication repository, providers, registration/OTP flows, controllers,
and screens remain app-owned because they depend on the live app's networking,
GetX/navigation, and broker-specific behavior. The current migration preserves
those call sites and the existing JSON field names.

Import the public contracts with:

```dart
import 'package:auth/auth.dart';
```
