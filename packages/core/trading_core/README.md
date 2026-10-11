# Trading core

Platform-independent primitives shared by OMS broker-house apps. It currently
owns a generic `ApiResponse<T>` result type and stateless JWT decoding,
expiration-date lookup, and expiry checks. Token storage, refresh scheduling,
and navigation remain app-owned.

```dart
import 'package:trading_core/trading_core.dart';

final result = ApiResponse<String>.success('ready');
final claims = JwtToken.decode(token);
final expired = JwtToken.isExpired(token);
```
