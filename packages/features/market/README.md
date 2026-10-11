# Market package

Shared market-domain logic for OMS broker-house apps. The first extracted API
are transport DTOs for securities, indices, market depth, and watchlists, plus
the immutable `MarketQuote` entity and quote, change, spread, range, duration,
and activity calculations, plus `MarketTickStore` for merging partial live
ticks by order book, and `MarketTickMessage` for classifying incoming market
websocket events.

The live Benemoy app adapts its current `MarketModel` to this entity through an
app-owned extension. Existing controller/view imports use compatibility exports
at their original paths; screens and presentation remain unchanged. Network
socket lifecycle, controllers, state, and market UI remain app-owned for now
and can be migrated in later, separately reviewable slices.

Import the public API with:

```dart
import 'package:market/market.dart';
```
