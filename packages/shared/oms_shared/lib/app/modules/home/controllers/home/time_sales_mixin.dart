part of '../home_controller.dart';

/// Time & sales and instrument news for time_sales_tab_widget.
mixin TimeSalesMixin on HomeState {
  void toggleTimeSalesChart() {
    isShowTimeSalesChart = !isShowTimeSalesChart;
    update(['timeAndSales']); // UI আপডেট করার জন্য
  }

  @override
  void _handleNewsTimeSalesMessage(String message) {
    // Process news and time sales
    try {
      final jsonResponse = jsonDecode(message);
      final messageType = jsonResponse['tp'];
      final data = jsonResponse['d'];

      if (messageType == 'tsm') {
        if (data is List) {
          var timeAndSalesData = timeAndSalesModelFromMap(data);
          timeAndSales.clear();
          timeAndSales.addAll(timeAndSalesData);
        } else if (data is Map<String, dynamic>) {
          timeAndSales.insert(0, TimeAndSalesModel.fromMap(data));
        }
        update(['timeAndSales']);
      } else if (messageType == 'tsb') {
        if (data is List) {
          var timeAndSalesData = data
              .map((e) => TimeAndSalesModel.fromMap(e))
              .toList();
          timeAndSalesHistory.clear();
          timeAndSalesHistory.addAll(timeAndSalesData);
        } else if (data is Map<String, dynamic>) {
          timeAndSalesHistory.insert(0, TimeAndSalesModel.fromMap(data));
        } else {
          timeAndSalesHistory.clear();
        }
        update([
          'timeAndSalesHistory',
        ]); // Add this if you have a widget using this data
      } else if (messageType == 'news') {
        if (data is List) {
          var allNews = newsModelFromMap(data);
          news.clear();
          news.addAll(allNews);
        } else if (data is Map<String, dynamic>) {
          news.insert(0, NewsModel.fromMap(data));
          //condition order book id jodi match kore tobe add hboe
        } else {
          news.clear();
        }
        update(['news']); // Add this if you have a widget using news data
      } else if (messageType == 'news_hist') {
        printLog("newsSingleItem: $data");
        if (data is List) {
          var allNews = newsModelFromMap(data);
          newsSingleItem.clear();
          newsSingleItem.addAll(allNews);
        } else if (data is Map<String, dynamic>) {
          newsSingleItem.insert(0, NewsModel.fromMap(data));
        } else {
          newsSingleItem.clear();
        }
        update([
          'newsSingleItem',
        ]); // Add this if you have a widget using this data
      }
    } catch (e) {
      printLog('❌ Error parsing Time & Sales data: $e');
    }
  }

  // Your existing subscribe methods (updated for WebSocketService)
  @override
  void subscribeTimeAndSales(String tp, String tid, String ob) {
    final body = jsonEncode({
      "ac": "subscribe",
      "tp": tp,
      "tid": int.parse(tid),
      "ob": int.parse(ob),
    });
    _webSocketService.sendMessage(AppConfig.newsTimeSalesSocketId, body);
    printLog("Time & Sales Sent subscribe: $body");
  }

  void subscribeTimeAndSalesNews(String tp, String tid) {
    final body = jsonEncode({
      "ac": "subscribe",
      "tp": tp,
      "tid": int.parse(tid),
    });
    printLog("Time & Sales Sent subscribe news: $body");
    _webSocketService.sendMessage(AppConfig.newsTimeSalesSocketId, body);
  }

}
