// Preserve the legacy app import path while the order DTO lives in orders.
export 'package:orders/orders.dart'
    show
        OrderSummaryModel,
        OrderSummaryData,
        ClientOrder,
        Summary,
        orderSummaryModelFromJson,
        orderSummaryModelToJson;
