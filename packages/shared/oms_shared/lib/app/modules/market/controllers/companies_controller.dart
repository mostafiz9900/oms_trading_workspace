import 'package:oms_shared/app/app_pkg.dart';
import 'package:get/get.dart';

import '../../../data/models/response/companies_model.dart';
import '../../../data/models/response/dividend_model.dart';
import '../../../data/models/response/eps_model.dart';

class CompaniesController extends GetxController {
  final GetConnect _httpClient = GetConnect();

  @override
  void onClose() {
    _httpClient.dispose();
    super.onClose();
  }

  final _connect = GetConnect(timeout: Duration(seconds: 30));

  CompaniesModel? companies;
  bool isLoading = false;
  String error = '';

  Future<CompaniesModel?> getCompanies(String symbol) async {
    try {
      isLoading = true;
      error = '';
      update(); // notify GetBuilder: show loader
      var url = '${AppConfig.baseURLChart}companies/symbol/$symbol';
      printLog('url:::get companies:$url');
      final response = await _connect.get(url);
      printLog('response:: companies:: ${response.statusCode}');
      printLog('response:: companies:: ${response.body}');
      if (response.statusCode == 200) {
        // response.body may be Map or String depending on GetConnect setup
        if (response.body is String) {
          companies = companiesModelFromMap(response.body as String);
          return companies;
        } else if (response.body is Map<String, dynamic>) {
          companies = CompaniesModel.fromMap(Map<String, dynamic>.from(response.body));
          return companies;
        } else {
          companies = CompaniesModel.fromMap(response.body ?? '');
          return companies;
        }
      } else {
        error = 'Error: ${response.statusCode} ${response.statusText ?? ''}';
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

  Future<DividendModel?> getDividend(String symbol) async {
    try {
      isLoading = true;
      error = '';
      update(); // notify GetBuilder: show loader
      var url = '${AppConfig.baseURLChart}dividends/symbol/$symbol';
      printLog('url:::get dividends:$url');
      final response = await _connect.get(url);
      printLog('response:: dividends:: ${response.statusCode}');
      printLog('response:: dividends:: ${response.body}');
      if (response.statusCode == 200) {
        // response.body may be Map or String depending on GetConnect setup
        if (response.body is String) {
          var dividend = dividendModelFromMap(response.body as String);
          return dividend;
        } else if (response.body is Map<String, dynamic>) {
          var dividend = DividendModel.fromMap(Map<String, dynamic>.from(response.body));
          return dividend;
        } else {
          var dividend = DividendModel.fromMap(response.body ?? '');
          return dividend;
        }
      } else {
        error = 'Error: ${response.statusCode} ${response.statusText ?? ''}';
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

  Future<EpsModel?> fetchQuarterEPS({required String symbol, required String quarter, required int year}) async {
    final url =
        "${AppConfig.baseURLChart}financial-reports_spetials/$symbol/$year/eps?quarter=$quarter&use_cumulative=false&search_previous_years=true";

    final response = await _httpClient.get(url);

    if (response.statusCode == 200 && response.body != null) {
      return EpsModel.fromMap(Map<String, dynamic>.from(response.body));
    }
    return null;
  }

  Future<Map<String, EpsModel>> getYearlyEPS(String symbol, int year) async {
    Map<String, EpsModel> epsMap = {};

    List<String> quarters = ["Q1", "Q2", "Q3", "Q4"];

    for (var q in quarters) {
      final data = await fetchQuarterEPS(symbol: symbol, quarter: q, year: year);
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
