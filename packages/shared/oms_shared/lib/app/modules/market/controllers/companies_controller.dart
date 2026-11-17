import 'package:dio/dio.dart';

import '../../../core/utils/helpers/log_helper.dart';
import '../../../core/values/app_config.dart';

import 'package:getxify/getxify.dart';

import '../../../data/models/response/companies_model.dart';
import '../../../data/models/response/dividend_model.dart';
import '../../../data/models/response/eps_model.dart';

class CompaniesController extends GetxController {
  final Dio _httpClient = Dio();

  @override
  void onClose() {
    _httpClient.close(force: true);
    _connect.close(force: true);
    super.onClose();
  }

  final _connect = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      responseType: ResponseType.json,
      validateStatus: (status) => status != null,
    ),
  );

  CompaniesModel? companies;
  bool isLoading = false;
  String error = '';

  Future<CompaniesModel?> getCompanies(String symbol) async {
    try {
      isLoading = true;
      error = '';
      update(); // notify GetBuilder: show loader

      var url = '${AppConfig.baseURLItch}api/company/fundamentals?code=$symbol';
      printLog('url:::get companies:$url');

      final response = await _connect.get(url);
      // printLog('response:: companies:: ${response.statusCode}');
      // printLog('response:: companies:: ${response.body}');

      if (response.statusCode == 200 && response.data != null) {
        // ১. response.body যদি String হিসেবে আসে (যেমন প্লেন টেক্সট বা এনকোডেড JSON)
        if (response.data is String) {
          companies = companiesModelFromJson(response.data as String);
          return companies;
        }
        // Dio decodes JSON responses to maps when the server sends JSON content.
        else if (response.data is Map<String, dynamic>) {
          companies = CompaniesModel.fromJson(
            Map<String, dynamic>.from(response.data),
          );
          return companies;
        }
        // ৩. ফ্যালব্যাক কেস: যদি কোনো কারণে অন্য ফরম্যাটে আসে, ডাইনামিক হ্যান্ডলিং
        else {
          try {
            // যদি বডি অলরেডি ম্যাপের মতো বিহেভ করে কিন্তু টাইপ এক্সপ্লিসিট না থাকে
            companies = CompaniesModel.fromJson(
              Map<String, dynamic>.from(response.data),
            );
            return companies;
          } catch (e) {
            error =
                'Parsing Error: Unexpected data format (${response.data.runtimeType})';
            printLog('error::: $error');
          }
        }
      } else {
        error = 'Error: ${response.statusCode} ${response.statusMessage ?? ''}';
      }
    } on Exception catch (e) {
      error = 'Exception: $e';
    } finally {
      isLoading = false;
      printLog('error::: $error');
      update(); // notify GetBuilder to refresh UI with new state (Data or Error)
    }
    return null;
  }

  Future<DividendModel?> getDividend(String symbol) async {
    try {
      isLoading = true;
      error = '';
      update(); // notify GetBuilder: show loader
      var url = '${AppConfig.baseURLChart}dividends/symbol/$symbol';
      printLog('url:::get dividends:$url');
      final response = await _connect.get(url);
      printLog('response:: dividends:: ${response.statusCode}');
      printLog('response:: dividends:: ${response.data}');
      if (response.statusCode == 200) {
        // Response data may be a Map or a JSON String depending on server headers.
        if (response.data is String) {
          var dividend = dividendModelFromMap(response.data as String);
          return dividend;
        } else if (response.data is Map<String, dynamic>) {
          var dividend = DividendModel.fromMap(
            Map<String, dynamic>.from(response.data),
          );
          return dividend;
        } else {
          var dividend = DividendModel.fromMap(response.data ?? '');
          return dividend;
        }
      } else {
        error = 'Error: ${response.statusCode} ${response.statusMessage ?? ''}';
      }
    } on Exception catch (e) {
      error = 'Exception: $e';
    } finally {
      isLoading = false;
      printLog('error::: $error');
      update(); // notify GetBuilder to refresh UI with new state
    }
    return null;
  }

  Future<EpsModel?> fetchQuarterEPS({
    required String symbol,
    required String quarter,
    required int year,
  }) async {
    final url =
        "${AppConfig.baseURLChart}financial-reports_spetials/$symbol/$year/eps?quarter=$quarter&use_cumulative=false&search_previous_years=true";

    final response = await _httpClient.get(url);

    if (response.statusCode == 200 && response.data != null) {
      return EpsModel.fromMap(Map<String, dynamic>.from(response.data));
    }
    return null;
  }

  Future<Map<String, EpsModel>> getYearlyEPS(String symbol, int year) async {
    Map<String, EpsModel> epsMap = {};

    List<String> quarters = ["Q1", "Q2", "Q3", "Q4"];

    for (var q in quarters) {
      final data = await fetchQuarterEPS(
        symbol: symbol,
        quarter: q,
        year: year,
      );
      if (data != null) {
        epsMap[q] = data;
      }
    }

    return epsMap;
  }
}

// 1. HTTP Client Provider

// 2. State Class

// 4. Provider

// 3. Notifier Class

// 4. Provider
