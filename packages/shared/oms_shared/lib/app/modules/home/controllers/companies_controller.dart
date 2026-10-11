import 'package:oms_shared/app/app_pkg.dart';
import 'package:get/get.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../data/models/response/companies_model.dart';
import '../../../data/models/response/dividend_model.dart';
import '../../../data/models/response/eps_model.dart';

class CompaniesController extends GetxController {
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

    final response = await GetConnect().get(url);

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
final httpClientProvider = Provider<GetConnect>((ref) => GetConnect());

// 2. State Class
class CompaniesState {
  final CompaniesModel? companies;
  final DividendModel? dividend;
  final Map<String, EpsModel>? yearlyEps;
  final bool isLoading;
  final String? error;

  const CompaniesState({this.companies, this.dividend, this.yearlyEps, this.isLoading = false, this.error});

  CompaniesState copyWith({
    CompaniesModel? companies,
    DividendModel? dividend,
    Map<String, EpsModel>? yearlyEps,
    bool? isLoading,
    String? error,
  }) {
    return CompaniesState(
      companies: companies ?? this.companies,
      dividend: dividend ?? this.dividend,
      yearlyEps: yearlyEps ?? this.yearlyEps,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CompaniesAsyncNotifier extends AsyncNotifier<CompaniesState> {
  @override
  CompaniesState build() {
    // Initial state
    return const CompaniesState();
  }

  Future<void> getCompanies(String symbol) async {
    final client = ref.read(httpClientProvider);

    state = AsyncValue.data(state.value!.copyWith(isLoading: true, error: null));

    try {
      final url = '${AppConfig.baseURLChart}companies/symbol/$symbol';
      final response = await client.get(url);

      if (response.statusCode == 200) {
        CompaniesModel? companies;

        if (response.body is String) {
          companies = companiesModelFromMap(response.body as String);
        } else if (response.body is Map<String, dynamic>) {
          companies = CompaniesModel.fromMap(Map<String, dynamic>.from(response.body));
        } else {
          companies = CompaniesModel.fromMap(response.body ?? '');
        }

        state = AsyncValue.data(state.value!.copyWith(companies: companies, isLoading: false));
      } else {
        state = AsyncValue.data(state.value!.copyWith(isLoading: false, error: 'Error: ${response.statusCode}'));
      }
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(isLoading: false, error: 'Exception: $e'));
    }
  }

  Future<void> getDividend(String symbol) async {
    final client = ref.read(httpClientProvider);

    state = AsyncValue.data(state.value!.copyWith(isLoading: true, error: null));

    try {
      final url = '${AppConfig.baseURLChart}dividends/symbol/$symbol';
      final response = await client.get(url);

      if (response.statusCode == 200) {
        DividendModel? dividend;

        if (response.body is String) {
          dividend = dividendModelFromMap(response.body as String);
        } else if (response.body is Map<String, dynamic>) {
          dividend = DividendModel.fromMap(Map<String, dynamic>.from(response.body));
        }

        state = AsyncValue.data(state.value!.copyWith(dividend: dividend, isLoading: false));
      } else {
        state = AsyncValue.data(state.value!.copyWith(isLoading: false, error: 'Error: ${response.statusCode}'));
      }
    } catch (e) {
      state = AsyncValue.data(state.value!.copyWith(isLoading: false, error: 'Exception: $e'));
    }
  }

  // Clear state
  void clear() {
    state = const AsyncValue.data(CompaniesState());
  }
}

// 4. Provider
final companiesProvider = AsyncNotifierProvider<CompaniesAsyncNotifier, CompaniesState>(CompaniesAsyncNotifier.new);

// 3. Notifier Class
class CompaniesNotifier extends Notifier<CompaniesState> {
  @override
  CompaniesState build() {
    // Initial state
    return const CompaniesState();
  }

  GetConnect get _client => ref.read(httpClientProvider);

  Future<void> getCompanies(String symbol) async {
    // Loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      final url = '${AppConfig.baseURLChart}companies/symbol/$symbol';
      printLog('url:::get companies:$url');

      final response = await _client.get(url);
      printLog('response:: companies:: ${response.statusCode}');
      printLog('response:: companies:: ${response.body}');

      if (response.statusCode == 200) {
        CompaniesModel? companies;

        if (response.body is String) {
          companies = companiesModelFromMap(response.body as String);
        } else if (response.body is Map<String, dynamic>) {
          companies = CompaniesModel.fromMap(Map<String, dynamic>.from(response.body));
        } else {
          companies = CompaniesModel.fromMap(response.body ?? '');
        }

        state = state.copyWith(companies: companies, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Error: ${response.statusCode} ${response.statusText ?? ''}');
      }
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: 'Exception: $e');
      printLog('error::: ${state.error}');
    }
  }

  Future<void> getDividend(String symbol) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final url = '${AppConfig.baseURLChart}dividends/symbol/$symbol';
      printLog('url:::get dividends:$url');

      final response = await _client.get(url);
      printLog('response:: dividends:: ${response.statusCode}');
      printLog('response:: dividends:: ${response.body}');

      if (response.statusCode == 200) {
        DividendModel? dividend;

        if (response.body is String) {
          dividend = dividendModelFromMap(response.body as String);
        } else if (response.body is Map<String, dynamic>) {
          dividend = DividendModel.fromMap(Map<String, dynamic>.from(response.body));
        } else {
          dividend = DividendModel.fromMap(response.body ?? '');
        }

        state = state.copyWith(dividend: dividend, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Error: ${response.statusCode} ${response.statusText ?? ''}');
      }
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: 'Exception: $e');
      printLog('error::: ${state.error}');
    }
  }

  Future<EpsModel?> _fetchQuarterEPS({required String symbol, required String quarter, required int year}) async {
    final url =
        "${AppConfig.baseURLChart}financial-reports_spetials/$symbol/$year/eps?quarter=$quarter&use_cumulative=false&search_previous_years=true";

    final response = await _client.get(url);

    if (response.statusCode == 200 && response.body != null) {
      return EpsModel.fromMap(Map<String, dynamic>.from(response.body));
    }
    return null;
  }

  Future<void> getYearlyEPS(String symbol, int year) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final Map<String, EpsModel> epsMap = {};
      final List<String> quarters = ["Q1", "Q2", "Q3", "Q4"];

      for (var quarter in quarters) {
        final data = await _fetchQuarterEPS(symbol: symbol, quarter: quarter, year: year);
        if (data != null) {
          epsMap[quarter] = data;
        }
      }

      state = state.copyWith(yearlyEps: epsMap, isLoading: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: 'Exception while fetching EPS: $e');
    }
  }

  // Clear state
  void clearState() {
    state = const CompaniesState();
  }
}

// 4. Provider
final companiesProvider2 = NotifierProvider<CompaniesNotifier, CompaniesState>(CompaniesNotifier.new);
