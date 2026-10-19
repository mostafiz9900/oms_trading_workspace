// Validates every broker-house app under apps/: env profiles, brand assets,
// company profile and native identities. Never prints profile values.
//
//   fvm dart run tool/validate_apps.dart
import 'dart:convert';
import 'dart:io';

const environments = ['uat', 'prod'];

const brandAssets = {
  'OMS_BRAND_LOGO_ASSET': 'assets/brand/logo_light.svg',
  'OMS_BRAND_DARK_LOGO_ASSET': 'assets/brand/logo_dark.svg',
  'OMS_BRAND_SPLASH_ASSET': 'assets/brand/splash_light.svg',
  'OMS_BRAND_DARK_SPLASH_ASSET': 'assets/brand/splash_dark.svg',
  'OMS_BRAND_ONBOARDING_FIRST_ASSET': 'assets/brand/onboarding_first.png',
  'OMS_BRAND_ONBOARDING_SECOND_ASSET': 'assets/brand/onboarding_second.png',
};

const httpKeys = [
  'OMS_API_BASE_URL',
  'OMS_API_CHART_BASE_URL',
  'OMS_API_ITCH_BASE_URL',
];

const socketKeys = [
  'OMS_SOCKET_BASE_URL',
  'OMS_SOCKET_MARKET_URL',
  'OMS_SOCKET_NEWS_URL',
  'OMS_SOCKET_INDEX_URL',
  'OMS_SOCKET_MARKET_DEPTH_URL',
  'OMS_SOCKET_NEWS_TIME_SALES_URL',
];

/// Optional: CSE feeds. Absent means "CSE uses the DSE feed".
const optionalSocketKeys = [
  'OMS_CSE_SOCKET_MARKET_URL',
  'OMS_CSE_SOCKET_INDEX_URL',
];

const colorKeys = [
  'OMS_BRAND_PRIMARY_COLOR',
  'OMS_BRAND_ACCENT_COLOR',
  'OMS_BRAND_BUTTON_COLOR',
];

final _errors = <String>[];
final _warnings = <String>[];
final _androidIds = <String, String>{};
final _iosIds = <String, String>{};

void main(List<String> arguments) {
  final root = Directory(arguments.isEmpty ? 'apps' : arguments.single);
  final apps =
      root
          .listSync()
          .whereType<Directory>()
          .where(
            (dir) =>
                File('${dir.path}/lib/src/house_profile.dart').existsSync(),
          )
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  for (final app in apps) {
    _validateApp(app);
  }
  for (final warning in _warnings) {
    stdout.writeln('warning: $warning');
  }
  if (_errors.isNotEmpty) {
    stderr.writeln('App validation failed:');
    for (final error in _errors) {
      stderr.writeln('  - $error');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'Validated ${apps.length} app(s): '
    '${apps.map((a) => _name(a.path)).join(', ')}',
  );
}

void _validateApp(Directory app) {
  final name = _name(app.path);
  final profileSource = File('${app.path}/lib/src/house_profile.dart')
      .readAsStringSync();
  final houseId = RegExp(r"houseId:\s*'([^']+)'")
      .firstMatch(profileSource)
      ?.group(1);
  _expect(houseId != null, name, 'lib/src/house_profile.dart has no houseId');
  if (profileSource.contains('TODO')) {
    _warnings.add('$name: lib/src/house_profile.dart still has TODO values');
  }

  for (final environment in environments) {
    _expect(
      File('${app.path}/lib/main_$environment.dart').existsSync(),
      name,
      'missing lib/main_$environment.dart',
    );
  }
  _expect(
    File('${app.path}/env/example.json').existsSync(),
    name,
    'missing env/example.json template',
  );

  // Env profiles are git-ignored, so they may be absent in a clean checkout.
  // Every profile that is present must be complete and consistent.
  String? houseName;
  for (final environment in environments) {
    final file = File('${app.path}/env/$environment.json');
    if (!file.existsSync()) {
      _warnings.add(
        '$name: env/$environment.json not present (copy env/example.json)',
      );
      continue;
    }
    final where = '$name/env/$environment.json';
    final env = _readJson(file, where);
    if (env == null) continue;

    _expect(
      env['OMS_ENV'] == environment,
      where,
      'OMS_ENV must be "$environment"',
    );
    _expect(
      env['OMS_HOUSE_ID'] == houseId,
      where,
      'OMS_HOUSE_ID must equal houseId in lib/src/house_profile.dart',
    );
    _expect(
      _nonEmpty(env['OMS_HOUSE_NAME']),
      where,
      'OMS_HOUSE_NAME is required',
    );
    houseName ??= env['OMS_HOUSE_NAME'] as String?;
    _expect(
      env['OMS_HOUSE_NAME'] == houseName,
      where,
      'OMS_HOUSE_NAME must be the same in every environment',
    );
    _expect(
      const {'en_US', 'bn_BD'}.contains(env['OMS_DEFAULT_LOCALE']),
      where,
      'OMS_DEFAULT_LOCALE must be en_US or bn_BD',
    );
    for (final key in httpKeys) {
      _expectUrl(env[key], where, key, const {'http', 'https'});
    }
    for (final key in socketKeys) {
      _expectUrl(env[key], where, key, const {'ws', 'wss'});
    }
    for (final key in optionalSocketKeys) {
      if (env[key] == null || '${env[key]}'.isEmpty) continue;
      _expectUrl(env[key], where, key, const {'ws', 'wss'});
    }
    for (final key in colorKeys) {
      _expect(
        env[key] is String &&
            RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(env[key] as String),
        where,
        '$key must be a #RRGGBB color',
      );
    }
    final contractUrl = env['OMS_CONTRACT_URL'];
    if (contractUrl is String && contractUrl.isNotEmpty) {
      _expectUrl(contractUrl, where, 'OMS_CONTRACT_URL', const {
        'http',
        'https',
      });
    }
    for (final entry in brandAssets.entries) {
      final path = (env[entry.key] as String?) ?? entry.value;
      _expect(
        File('${app.path}/$path').existsSync(),
        where,
        'brand asset $path is missing',
      );
    }
  }

  final androidId =
      _match(
        '${app.path}/android/app/build.gradle',
        r'''applicationId\s*=?\s*["']([^"']+)["']''',
      ) ??
      _match(
        '${app.path}/android/app/build.gradle.kts',
        r'''applicationId\s*=?\s*["']([^"']+)["']''',
      );
  final iosId = _match(
    '${app.path}/ios/Runner.xcodeproj/project.pbxproj',
    r'PRODUCT_BUNDLE_IDENTIFIER = ([A-Za-z0-9.\-]+);',
  );
  _unique(_androidIds, androidId, name, 'Android applicationId');
  _unique(_iosIds, iosId, name, 'iOS bundle id');
  _expect(
    File('${app.path}/android/app/google-services.json').existsSync(),
    name,
    'missing android/app/google-services.json (run flutterfire configure)',
  );
  _expect(
    File('${app.path}/ios/Runner/GoogleService-Info.plist').existsSync(),
    name,
    'missing ios/Runner/GoogleService-Info.plist (run flutterfire configure)',
  );
}

void _unique(Map<String, String> seen, String? id, String app, String label) {
  if (id == null) {
    _errors.add('$app: could not read $label');
    return;
  }
  final other = seen[id];
  _expect(other == null, app, '$label is also used by "$other"');
  seen[id] = app;
}

String? _match(String path, String pattern) {
  final file = File(path);
  if (!file.existsSync()) return null;
  return RegExp(pattern).firstMatch(file.readAsStringSync())?.group(1);
}

Map<String, dynamic>? _readJson(File file, String where) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) return decoded;
    _errors.add('$where: root must be a JSON object');
  } on FormatException catch (error) {
    _errors.add('$where: invalid JSON (${error.message})');
  }
  return null;
}

void _expectUrl(Object? value, String where, String key, Set<String> schemes) {
  final uri = value is String ? Uri.tryParse(value) : null;
  _expect(
    uri != null && uri.hasAuthority && schemes.contains(uri.scheme),
    where,
    '$key must be an absolute ${schemes.join('/')} URL',
  );
}

void _expect(bool condition, String where, String message) {
  if (!condition) _errors.add('$where: $message');
}

bool _nonEmpty(Object? value) => value is String && value.trim().isNotEmpty;

String _name(String path) => path.split(Platform.pathSeparator).last;
