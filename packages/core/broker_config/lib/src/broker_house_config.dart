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
        'assets/icons/ic_appicon.png',
      ),
      logoAsset: _value(
        'OMS_BRAND_LOGO_ASSET',
        fallbackValues,
        '',
        'assets/svg_image/logoSvg.svg',
      ),
      darkLogoAsset: _value(
        'OMS_BRAND_DARK_LOGO_ASSET',
        fallbackValues,
        '',
        'assets/svg_image/logoSvgWhite.svg',
      ),
      lightSplashAsset: _value(
        'OMS_BRAND_SPLASH_ASSET',
        fallbackValues,
        '',
        'assets/svg_image/Splash.svg',
      ),
      darkSplashAsset: _value(
        'OMS_BRAND_DARK_SPLASH_ASSET',
        fallbackValues,
        '',
        'assets/svg_image/Splash-dart.svg',
      ),
      onboardingFirstAsset: _value(
        'OMS_BRAND_ONBOARDING_FIRST_ASSET',
        fallbackValues,
        '',
        'assets/images/onboard_01.png',
      ),
      onboardingSecondAsset: _value(
        'OMS_BRAND_ONBOARDING_SECOND_ASSET',
        fallbackValues,
        '',
        'assets/images/onboard_02.png',
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
      contractUrl: (() {
        final compileTimeValue = _compileTimeValue('OMS_CONTRACT_URL');
        if (compileTimeValue.isNotEmpty) {
          return compileTimeValue;
        }
        return (fallbackValues['OMS_CONTRACT_URL'] ?? '').trim();
      })(),
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
