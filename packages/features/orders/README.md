# Orders package

Shared order request/response DTOs and the broker-neutral `OrderRepository`
command contract for OMS broker-house apps. It owns order submission and
cancellation payloads plus order list, status, and summary models. Models
retain the existing Benemoy JSON field mapping.

The Benemoy app keeps exports at its previous model paths, and its existing
websocket `OrderManagementService` implements the package contract. Websocket
connection lifecycle, controllers, broker-specific confirmation holder, and
UI remain app-owned.

```dart
import 'package:orders/orders.dart';
```
