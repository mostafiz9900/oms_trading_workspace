import 'stock_exchange.dart';

/// Build-time identity, branding, localization, and endpoint configuration
/// shared by OMS broker-house applications.
class BrokerHouseConfig {
  const BrokerHouseConfig({
    required this.houseId,
    required this.displayName,
    required this.environment,
    required this.apiBaseUrl,
    required this.chartBaseUrl,
    required this.itchBaseUrl,
    required this.socketBaseUrl,
    required this.marketSocketUrl,
    required this.newsSocketUrl,
    required this.indexSocketUrl,
    required this.marketDepthSocketUrl,
    required this.newsTimeSalesSocketUrl,
    required this.appIconAsset,
    required this.logoAsset,
    required this.darkLogoAsset,
    required this.lightSplashAsset,
    required this.darkSplashAsset,
    required this.onboardingFirstAsset,
    required this.onboardingSecondAsset,
    required this.defaultLocale,
    required this.primaryColor,
    required this.accentColor,
    required this.buttonColor,
    required this.contractUrl,
    this.cseMarketSocketUrl = '',
    this.cseIndexSocketUrl = '',
    this.cseMarketDepthSocketUrl = '',
    this.cseNewsTimeSalesSocketUrl = '',
  });

  final String houseId;
  final String displayName;
  final String environment;
  final String apiBaseUrl;
  final String chartBaseUrl;
  final String itchBaseUrl;
  final String socketBaseUrl;
  final String marketSocketUrl;
  final String newsSocketUrl;
  final String indexSocketUrl;
  final String marketDepthSocketUrl;
  final String newsTimeSalesSocketUrl;
  final String appIconAsset;
  final String logoAsset;
  final String darkLogoAsset;
  final String lightSplashAsset;
  final String darkSplashAsset;
  final String onboardingFirstAsset;
  final String onboardingSecondAsset;
  final String defaultLocale;
  final String primaryColor;
  final String accentColor;
  final String buttonColor;
  final String contractUrl;

  /// CSE market / index feeds (`OMS_CSE_SOCKET_MARKET_URL`,
  /// `OMS_CSE_SOCKET_INDEX_URL`). Optional: empty means "same as DSE" until
  /// the CSE feed exists. Read them through [marketSocketUrlFor] /
  /// [indexSocketUrlFor].
  final String cseMarketSocketUrl;
  final String cseIndexSocketUrl;

  /// CSE market depth / news & time-and-sales feeds
  /// (`OMS_CSE_SOCKET_MARKET_DEPTH_URL`, `OMS_CSE_SOCKET_NEWS_TIME_SALES_URL`).
  /// Optional, like the two above.
  final String cseMarketDepthSocketUrl;
  final String cseNewsTimeSalesSocketUrl;

  /// Market feed of [exchange]; CSE falls back to the DSE feed when no CSE
  /// URL is configured.
  String marketSocketUrlFor(StockExchange exchange) =>
      exchange == StockExchange.cse && cseMarketSocketUrl.isNotEmpty
      ? cseMarketSocketUrl
      : marketSocketUrl;

  /// Index feed of [exchange]; CSE falls back to the DSE feed when no CSE
  /// URL is configured.
  String indexSocketUrlFor(StockExchange exchange) =>
      exchange == StockExchange.cse && cseIndexSocketUrl.isNotEmpty
      ? cseIndexSocketUrl
      : indexSocketUrl;

  /// Market depth feed of [exchange]; CSE falls back to the DSE feed when no
  /// CSE URL is configured.
  String marketDepthSocketUrlFor(StockExchange exchange) =>
      exchange == StockExchange.cse && cseMarketDepthSocketUrl.isNotEmpty
      ? cseMarketDepthSocketUrl
      : marketDepthSocketUrl;

  /// News and time & sales feed of [exchange]; CSE falls back to the DSE feed
  /// when no CSE URL is configured.
  String newsTimeSalesSocketUrlFor(StockExchange exchange) =>
      exchange == StockExchange.cse && cseNewsTimeSalesSocketUrl.isNotEmpty
      ? cseNewsTimeSalesSocketUrl
      : newsTimeSalesSocketUrl;

  factory BrokerHouseConfig.load({
    required String environment,
    Map<String, String> fallbackValues = const {},
  }) {
    final config = BrokerHouseConfig(
      houseId: _value(
        'OMS_HOUSE_ID',
        fallbackValues,
        'OMS_HOUSE_ID',
        'benemoy',
      ),
      displayName: _value(
        'OMS_HOUSE_NAME',
        fallbackValues,
        'OMS_HOUSE_NAME',
        'Benemoy',
      ),
      environment: environment,
      apiBaseUrl: _value('OMS_API_BASE_URL', fallbackValues, 'BASE_URL'),
      chartBaseUrl: _value(
        'OMS_API_CHART_BASE_URL',
        fallbackValues,
        'BASE_URL_CHART',
      ),
      itchBaseUrl: _value(
        'OMS_API_ITCH_BASE_URL',
        fallbackValues,
        'BASE_URL_ITCH',
      ),
      socketBaseUrl: _value(
        'OMS_SOCKET_BASE_URL',
        fallbackValues,
        'SOCKET_BASE_URL',
      ),
      marketSocketUrl: _value(
        'OMS_SOCKET_MARKET_URL',
        fallbackValues,
        'market_url',
      ),
      newsSocketUrl: _value('OMS_SOCKET_NEWS_URL', fallbackValues, 'NEWS_URL'),
      indexSocketUrl: _value(
        'OMS_SOCKET_INDEX_URL',
        fallbackValues,
        'INDEX_URL',
      ),
      marketDepthSocketUrl: _value(
        'OMS_SOCKET_MARKET_DEPTH_URL',
        fallbackValues,
        'MARKET_DEPTH',
      ),
      newsTimeSalesSocketUrl: _value(
        'OMS_SOCKET_NEWS_TIME_SALES_URL',
        fallbackValues,
        'NEWS_URL_TIME_SALES',
      ),
      appIconAsset: _value(
        'OMS_BRAND_APP_ICON_ASSET',
        fallbackValues,
        '',
        'assets/brand/app_icon.png',
      ),
      logoAsset: _value(
        'OMS_BRAND_LOGO_ASSET',
        fallbackValues,
        '',
        'assets/brand/logo_light.svg',
      ),
      darkLogoAsset: _value(
        'OMS_BRAND_DARK_LOGO_ASSET',
        fallbackValues,
        '',
        'assets/brand/logo_dark.svg',
      ),
      lightSplashAsset: _value(
        'OMS_BRAND_SPLASH_ASSET',
        fallbackValues,
        '',
        'assets/brand/splash_light.svg',
      ),
      darkSplashAsset: _value(
        'OMS_BRAND_DARK_SPLASH_ASSET',
        fallbackValues,
        '',
        'assets/brand/splash_dark.svg',
      ),
      onboardingFirstAsset: _value(
        'OMS_BRAND_ONBOARDING_FIRST_ASSET',
        fallbackValues,
        '',
        'assets/brand/onboarding_first.png',
      ),
      onboardingSecondAsset: _value(
        'OMS_BRAND_ONBOARDING_SECOND_ASSET',
        fallbackValues,
        '',
        'assets/brand/onboarding_second.png',
      ),
      defaultLocale: _value('OMS_DEFAULT_LOCALE', fallbackValues, '', 'en_US'),
      primaryColor: _value(
        'OMS_BRAND_PRIMARY_COLOR',
        fallbackValues,
        '',
        '#184A94',
      ),
      accentColor: _value(
        'OMS_BRAND_ACCENT_COLOR',
        fallbackValues,
        '',
        '#177DFF',
      ),
      buttonColor: _value(
        'OMS_BRAND_BUTTON_COLOR',
        fallbackValues,
        '',
        '#177DFF',
      ),
      contractUrl: _optionalValue('OMS_CONTRACT_URL', fallbackValues),
      cseMarketSocketUrl: _optionalValue(
        'OMS_CSE_SOCKET_MARKET_URL',
        fallbackValues,
      ),
      cseIndexSocketUrl: _optionalValue(
        'OMS_CSE_SOCKET_INDEX_URL',
        fallbackValues,
      ),
      cseMarketDepthSocketUrl: _optionalValue(
        'OMS_CSE_SOCKET_MARKET_DEPTH_URL',
        fallbackValues,
      ),
      cseNewsTimeSalesSocketUrl: _optionalValue(
        'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL',
        fallbackValues,
      ),
    );
    config._validate();
    return config;
  }

  static String _value(
    String define,
    Map<String, String> fallbackValues,
    String dotenvKey, [
    String fallback = '',
  ]) {
    final defined = _compileTimeValue(define);
    final value = defined.isNotEmpty
        ? defined
        : (dotenvKey.isEmpty
              ? fallback
              : fallbackValues[dotenvKey]?.trim() ?? fallback);
    if (value.isEmpty || value == 'null') {
      throw StateError('Missing configuration "$define".');
    }
    return value;
  }

  /// A key that may be absent: the compile-time define, else the fallback
  /// map, else empty.
  static String _optionalValue(
    String define,
    Map<String, String> fallbackValues,
  ) {
    final compileTimeValue = _compileTimeValue(define);
    if (compileTimeValue.isNotEmpty) return compileTimeValue;
    return (fallbackValues[define] ?? '').trim();
  }

  static String _compileTimeValue(String name) {
    switch (name) {
      case 'OMS_HOUSE_ID':
        return const String.fromEnvironment('OMS_HOUSE_ID').trim();
      case 'OMS_HOUSE_NAME':
        return const String.fromEnvironment('OMS_HOUSE_NAME').trim();
      case 'OMS_API_BASE_URL':
        return const String.fromEnvironment('OMS_API_BASE_URL').trim();
      case 'OMS_API_CHART_BASE_URL':
        return const String.fromEnvironment('OMS_API_CHART_BASE_URL').trim();
      case 'OMS_API_ITCH_BASE_URL':
        return const String.fromEnvironment('OMS_API_ITCH_BASE_URL').trim();
      case 'OMS_SOCKET_BASE_URL':
        return const String.fromEnvironment('OMS_SOCKET_BASE_URL').trim();
      case 'OMS_SOCKET_MARKET_URL':
        return const String.fromEnvironment('OMS_SOCKET_MARKET_URL').trim();
      case 'OMS_SOCKET_NEWS_URL':
        return const String.fromEnvironment('OMS_SOCKET_NEWS_URL').trim();
      case 'OMS_SOCKET_INDEX_URL':
        return const String.fromEnvironment('OMS_SOCKET_INDEX_URL').trim();
      case 'OMS_SOCKET_MARKET_DEPTH_URL':
        return const String.fromEnvironment('OMS_SOCKET_MARKET_DEPTH_URL')
            .trim();
      case 'OMS_SOCKET_NEWS_TIME_SALES_URL':
        return const String.fromEnvironment('OMS_SOCKET_NEWS_TIME_SALES_URL')
            .trim();
      case 'OMS_BRAND_APP_ICON_ASSET':
        return const String.fromEnvironment('OMS_BRAND_APP_ICON_ASSET').trim();
      case 'OMS_BRAND_LOGO_ASSET':
        return const String.fromEnvironment('OMS_BRAND_LOGO_ASSET').trim();
      case 'OMS_BRAND_DARK_LOGO_ASSET':
        return const String.fromEnvironment('OMS_BRAND_DARK_LOGO_ASSET').trim();
      case 'OMS_BRAND_SPLASH_ASSET':
        return const String.fromEnvironment('OMS_BRAND_SPLASH_ASSET').trim();
      case 'OMS_BRAND_DARK_SPLASH_ASSET':
        return const String.fromEnvironment('OMS_BRAND_DARK_SPLASH_ASSET')
            .trim();
      case 'OMS_BRAND_ONBOARDING_FIRST_ASSET':
        return const String.fromEnvironment('OMS_BRAND_ONBOARDING_FIRST_ASSET')
            .trim();
      case 'OMS_BRAND_ONBOARDING_SECOND_ASSET':
        return const String.fromEnvironment('OMS_BRAND_ONBOARDING_SECOND_ASSET')
            .trim();
      case 'OMS_DEFAULT_LOCALE':
        return const String.fromEnvironment('OMS_DEFAULT_LOCALE').trim();
      case 'OMS_BRAND_PRIMARY_COLOR':
        return const String.fromEnvironment('OMS_BRAND_PRIMARY_COLOR').trim();
      case 'OMS_BRAND_ACCENT_COLOR':
        return const String.fromEnvironment('OMS_BRAND_ACCENT_COLOR').trim();
      case 'OMS_BRAND_BUTTON_COLOR':
        return const String.fromEnvironment('OMS_BRAND_BUTTON_COLOR').trim();
      case 'OMS_CONTRACT_URL':
        return const String.fromEnvironment('OMS_CONTRACT_URL').trim();
      case 'OMS_CSE_SOCKET_MARKET_URL':
        return const String.fromEnvironment('OMS_CSE_SOCKET_MARKET_URL').trim();
      case 'OMS_CSE_SOCKET_INDEX_URL':
        return const String.fromEnvironment('OMS_CSE_SOCKET_INDEX_URL').trim();
      case 'OMS_CSE_SOCKET_MARKET_DEPTH_URL':
        return const String.fromEnvironment(
          'OMS_CSE_SOCKET_MARKET_DEPTH_URL',
        ).trim();
      case 'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL':
        return const String.fromEnvironment(
          'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL',
        ).trim();
      default:
        throw ArgumentError.value(name, 'name', 'Unknown broker config key');
    }
  }

  void _validate() {
    if (!RegExp(r'^[a-z0-9][a-z0-9_-]*$').hasMatch(houseId)) {
      throw StateError('OMS_HOUSE_ID must be a lowercase slug.');
    }
    if (displayName.trim().isEmpty) {
      throw StateError('OMS_HOUSE_NAME must not be empty.');
    }
    if (!const {'en_US', 'bn_BD'}.contains(defaultLocale)) {
      throw StateError('OMS_DEFAULT_LOCALE must be en_US or bn_BD.');
    }
    _validateUrl('OMS_API_BASE_URL', apiBaseUrl, const {'http', 'https'});
    _validateUrl('OMS_API_CHART_BASE_URL', chartBaseUrl, const {
      'http',
      'https',
    });
    _validateUrl('OMS_API_ITCH_BASE_URL', itchBaseUrl, const {'http', 'https'});
    _validateUrl('OMS_SOCKET_BASE_URL', socketBaseUrl, const {'ws', 'wss'});
    _validateUrl('OMS_SOCKET_MARKET_URL', marketSocketUrl, const {'ws', 'wss'});
    _validateUrl('OMS_SOCKET_NEWS_URL', newsSocketUrl, const {'ws', 'wss'});
    _validateUrl('OMS_SOCKET_INDEX_URL', indexSocketUrl, const {'ws', 'wss'});
    _validateUrl('OMS_SOCKET_MARKET_DEPTH_URL', marketDepthSocketUrl, const {
      'ws',
      'wss',
    });
    _validateUrl(
      'OMS_SOCKET_NEWS_TIME_SALES_URL',
      newsTimeSalesSocketUrl,
      const {'ws', 'wss'},
    );
    if (contractUrl.isNotEmpty) {
      _validateUrl('OMS_CONTRACT_URL', contractUrl, const {'http', 'https'});
    }
    if (cseMarketSocketUrl.isNotEmpty) {
      _validateUrl('OMS_CSE_SOCKET_MARKET_URL', cseMarketSocketUrl, const {
        'ws',
        'wss',
      });
    }
    if (cseIndexSocketUrl.isNotEmpty) {
      _validateUrl('OMS_CSE_SOCKET_INDEX_URL', cseIndexSocketUrl, const {
        'ws',
        'wss',
      });
    }
    if (cseMarketDepthSocketUrl.isNotEmpty) {
      _validateUrl(
        'OMS_CSE_SOCKET_MARKET_DEPTH_URL',
        cseMarketDepthSocketUrl,
        const {'ws', 'wss'},
      );
    }
    if (cseNewsTimeSalesSocketUrl.isNotEmpty) {
      _validateUrl(
        'OMS_CSE_SOCKET_NEWS_TIME_SALES_URL',
        cseNewsTimeSalesSocketUrl,
        const {'ws', 'wss'},
      );
    }
    _validateColor('OMS_BRAND_PRIMARY_COLOR', primaryColor);
    _validateColor('OMS_BRAND_ACCENT_COLOR', accentColor);
    _validateColor('OMS_BRAND_BUTTON_COLOR', buttonColor);
  }

  static void _validateUrl(String name, String value, Set<String> schemes) {
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasAuthority || !schemes.contains(uri.scheme)) {
      throw StateError(
        '$name must be an absolute URL using ${schemes.join('/')}',
      );
    }
  }

  static void _validateColor(String name, String value) {
    if (!RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)) {
      throw StateError('$name must be a #RRGGBB color.');
    }
  }
}
