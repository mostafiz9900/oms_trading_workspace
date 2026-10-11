import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:orders/orders.dart' show OrderRepository;
import 'package:get/get.dart';

import '../../app_pkg.dart';
import '../models/response/user_balance.dart';
import '../models/request/update_order_holder.dart';
import '../models/response/order_status_details_model.dart';

class OrderManagementService extends GetxService implements OrderRepository {
  static OrderManagementService get to => Get.find();
  final WebSocketService _wsService = WebSocketService.instance;

  UserOrderModel userOrder = UserOrderModel();
  List<UserOrder> userOrderList = [];
  UserBalance? userBalanceData;
  OrderStatusDetailsModel orderStatusDetails = OrderStatusDetailsModel();

  final Map<String, Function(String)> _onSuccessCallbacks = {};
  final Map<String, Function(String)> _onErrorCallbacks = {};
  final Map<String, Function(Map<String, dynamic>)> _onStatusCallbacks = {};

  void getUserOrder(String boId, String token) {
    final url = '${AppConfig.socketBaseUrl}order/$boId/?token=$token';
    _wsService.connect(
      socketId: 'user_order',
      url: url,
      onMessage: _handleOrderSocketMessage,
    );
  }

  void _handleOrderSocketMessage(String message) {
    try {
      final jsonResponse = jsonDecode(message);
      final msgType = jsonResponse['message_type'];
      final data = jsonResponse['data'];

      if (msgType == AppConstants.connection) {
        userOrder = UserOrderModel.fromJson(jsonResponse);
        userOrderList.clear();
        for (final order in jsonResponse['data']) {
          userOrderList.add(UserOrder.fromJson(order));
        }
        _updateUI([AppConstants.orderList]);
      } else if (msgType == AppConstants.orderReport) {
        UserOrder singleData = UserOrder.fromJson(data);
        final exists =
            userOrder.data?.any(
              (e) =>
                  e.clientOrderId?.trim() == singleData.clientOrderId?.trim(),
            ) ??
            false;

        if (exists) {
          var newData = userOrder.data
              ?.map(
                (e) =>
                    e.clientOrderId?.trim() == singleData.clientOrderId?.trim()
                    ? singleData
                    : e,
              )
              .toList();
          userOrder = userOrder.copyWith(data: newData);
        } else {
          userOrder = userOrder.copyWith(
            data: [...?userOrder.data, singleData],
          );
        }
        _updateUI([AppConstants.orderList]);

        final cId = singleData.clientOrderId;
        if (cId != null && _onSuccessCallbacks.containsKey(cId)) {
          _onSuccessCallbacks[cId]?.call("Operation Successful!");
          _onSuccessCallbacks.remove(cId);
          _onErrorCallbacks.remove(cId);
        }
      } else if (msgType == AppConstants.orderError) {
        final errorMsg = jsonResponse['message'] ?? 'Action Failed';
        if (data != null && data['client_order_id'] != null) {
          final cId = data['client_order_id'];
          if (_onErrorCallbacks.containsKey(cId)) {
            _onErrorCallbacks[cId]?.call(errorMsg);
            _onErrorCallbacks.remove(cId);
            _onSuccessCallbacks.remove(cId);
          }
        } else {
          Get.snackbar(
            "Error",
            errorMsg,
            backgroundColor: Get.theme.colorScheme.error,
            colorText: Get.theme.colorScheme.onError,
          );
        }
      } else if (msgType == AppConstants.orderStatus) {
        final cId = data['client_order_id'] ?? jsonResponse['client_order_id'];
        if (cId != null && _onStatusCallbacks.containsKey(cId)) {
          _onStatusCallbacks[cId]?.call(data);
          _onStatusCallbacks.remove(cId);
        }
      }
    } catch (e) {
      debugPrint('Error processing user order: $e');
    }
  }

  @override
  void placeOrder(
    OrderConfirmRequest request,
    void Function(String) onSuccess,
    void Function(String) onError,
  ) {
    final cId =
        request.clientOrderId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    request.clientOrderId = cId;

    _onSuccessCallbacks[cId] = onSuccess;
    _onErrorCallbacks[cId] = onError;
    _wsService.sendMessage('user_order', jsonEncode(request.toJson()));
  }

  @override
  void modifyOrder(
    OrderConfirmRequest request,
    void Function(String) onSuccess,
    void Function(String) onError,
  ) {
    final cId =
        request.clientOrderId ??
        DateTime.now().millisecondsSinceEpoch.toString();
    request.clientOrderId = cId;
    _onSuccessCallbacks[cId] = onSuccess;
    _onErrorCallbacks[cId] = onError;
    _wsService.sendMessage(
      'user_order',
      jsonEncode(request.toJsonReplaceOrder()),
    );
  }

  @override
  void cancelOrder(
    UpdateOrderHolder request,
    void Function(String) onSuccess,
    void Function(String) onError,
  ) {
    final cId = request.clientOrderId;
    // request.clientOrderId = cId;
    _onSuccessCallbacks[cId] = onSuccess;
    _onErrorCallbacks[cId] = onError;
    _wsService.sendMessage('user_order', jsonEncode(request.toJson()));
  }

  @override
  void checkOrderStatus(
    Map<String, dynamic> requestBody,
    void Function(Map<String, dynamic>) onStatusReceived,
  ) {
    final cId = requestBody['client_order_id'];
    if (cId != null) _onStatusCallbacks[cId] = onStatusReceived;
    _wsService.sendMessage('user_order', jsonEncode(requestBody));
  }

  void userBalance(String boId, String token) {
    final url = '${AppConfig.socketBaseUrl}cash/$boId/?token=$token';
    _wsService.connect(
      socketId: 'user_balance',
      url: url,
      onMessage: (message) {
        final data = jsonDecode(message)['data'];
        userBalanceData = userBalanceFromJson(data).first;
        _updateUI([]);
      },
    );
  }

  void _updateUI(List<String> ids) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().update(ids);
    }
  }
}
