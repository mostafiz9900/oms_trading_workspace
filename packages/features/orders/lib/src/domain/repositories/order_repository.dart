import '../../data/models/requests/order_confirm_request.dart';
import '../../data/models/requests/update_order_holder.dart';

/// Callback used to report the result of a broker order command.
typedef OrderCommandCallback = void Function(String message);

/// Callback used to report a broker order status payload.
typedef OrderStatusCallback = void Function(Map<String, dynamic> status);

/// Broker-neutral order commands consumed by trading application features.
///
/// Connection lifecycle, websocket serialization, and UI notifications belong
/// in each broker-house application's adapter.
abstract interface class OrderRepository {
  void placeOrder(
    OrderConfirmRequest request,
    OrderCommandCallback onSuccess,
    OrderCommandCallback onError,
  );

  void modifyOrder(
    OrderConfirmRequest request,
    OrderCommandCallback onSuccess,
    OrderCommandCallback onError,
  );

  void cancelOrder(
    UpdateOrderHolder request,
    OrderCommandCallback onSuccess,
    OrderCommandCallback onError,
  );

  void checkOrderStatus(
    Map<String, dynamic> requestBody,
    OrderStatusCallback onStatusReceived,
  );
}
