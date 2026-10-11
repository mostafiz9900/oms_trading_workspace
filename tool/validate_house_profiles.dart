import 'dart:convert';
import 'dart:io';

final _errors = <String>[];
final _applicationIds = <String, String>{};

void main(List<String> arguments) {
  final root = Directory(arguments.isEmpty ? 'apps' : arguments.single);
  final manifests =
      root
          .listSync(recursive: true)
          .whereType<File>()
          .where(
            (file) =>
                file.path.contains('/config/houses/brands/') &&
                file.uri.pathSegments.last == 'manifest.json',
          )
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  if (manifests.isEmpty) {
    stdout.writeln('No broker-house branding manifests found.');
    return;
  }
  for (final file in manifests) {
    _validateManifest(file);
  }
  if (_errors.isNotEmpty) {
    stderr.writeln('Broker-house profile validation failed:');
    for (final error in _errors) {
      stderr.writeln('  - $error');
    }
    exitCode = 1;
    return;
  }
  stdout.writeln('Validated ${manifests.length} broker-house manifest(s).');
}

void _validateManifest(File file) {
  final path = file.path;
  final houseId = file.parent.path
      .split(Platform.pathSeparator)
      .where((segment) => segment.isNotEmpty)
      .last;
  const marker = '/config/houses/brands/';
  final markerIndex = path.indexOf(marker);
  if (markerIndex < 1) {
    _errors.add('$path: expected it under apps/<app>/config/houses/brands/');
    return;
  }
  final appRoot = path.substring(0, markerIndex);
  final androidFile = File(
    '$appRoot/config/houses/android/$houseId.properties',
  );
  final manifest = _readJson(file);
  if (manifest == null) return;

  _expect(manifest['schemaVersion'] == 1, path, 'schemaVersion must be 1');
  _expect(
    manifest['houseId'] == houseId,
    path,
    'houseId must match directory "$houseId"',
  );
  _expect(
    _nonEmptyString(manifest['appName']),
    path,
    'appName must be a non-empty string',
  );

  final branding = _asMap(manifest['branding']);
  if (branding == null) {
    _errors.add('$path: branding must be an object');
  } else {
    for (final key in ['logoLight', 'logoDark', 'appIcon']) {
      _expect(
        _nonEmptyString(branding[key]),
        path,
        'branding.$key must be a non-empty asset path',
      );
    }
    for (final key in ['primaryColor', 'secondaryColor']) {
      final color = branding[key];
      _expect(
        color == null ||
            (color is String &&
                RegExp(r'^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$')
                    .hasMatch(color)),
        path,
        'branding.$key must be null or a hex color',
      );
    }
  }

  final locales = _asMap(manifest['locales']);
  if (locales == null) {
    _errors.add('$path: locales must be an object');
  } else {
    final supported = locales['supported'];
    _expect(
      supported is List &&
          supported.isNotEmpty &&
          supported.every(
            (locale) => locale is String && locale.trim().isNotEmpty,
          ),
      path,
      'locales.supported must contain locale codes',
    );
    if (supported is List) {
      _expect(
        supported.contains(locales['default']),
        path,
        'locales.default must be in locales.supported',
      );
    }
  }

  final capabilities = _asMap(manifest['capabilities']);
  if (capabilities == null) {
    _errors.add('$path: capabilities must be an object');
  } else {
    for (final entry in capabilities.entries) {
      _expect(
        entry.value is bool,
        path,
        'capabilities.${entry.key} must be true or false',
      );
    }
  }

  for (final sectionName in ['documents', 'support']) {
    final section = _asMap(manifest[sectionName]);
    _expect(section != null, path, '$sectionName must be an object');
    if (section == null) continue;
    for (final entry in section.entries) {
      final value = entry.value;
      _expect(
        value == null || value is String,
        path,
        '$sectionName.${entry.key} must be a string or null',
      );
      if (value is String &&
          value.isNotEmpty &&
          entry.key.toLowerCase().contains('url')) {
        final uri = Uri.tryParse(value);
        _expect(
          uri != null && uri.hasAuthority && uri.scheme == 'https',
          path,
          '$sectionName.${entry.key} must be an absolute HTTPS URL',
        );
      }
    }
  }

  _expect(
    androidFile.existsSync(),
    path,
    'missing Android metadata at ${androidFile.path}',
  );
  if (!androidFile.existsSync()) return;
  final properties = _readProperties(androidFile);
  final applicationId = properties['applicationId'];
  _expect(
    applicationId != null &&
        RegExp(r'^[A-Za-z][A-Za-z0-9_]*(\.[A-Za-z][A-Za-z0-9_]*)+$')
            .hasMatch(applicationId),
    path,
    'Android applicationId is missing or invalid',
  );
  _expect(
    properties['displayName'] == manifest['appName'],
    path,
    'Android displayName must match appName',
  );
  if (applicationId != null) {
    final nativeId = _nativeApplicationId(appRoot);
    _expect(
      nativeId == applicationId,
      path,
      'Android applicationId must match android/app/build.gradle '
      '(found "${nativeId ?? 'none'}")',
    );
    final previousHouse = _applicationIds[applicationId];
    _expect(
      previousHouse == null,
      path,
      'Android applicationId duplicates house "$previousHouse"',
    );
    _applicationIds[applicationId] = houseId;
  }

  _validateDartDefineProfiles(file, houseId, manifest);
}

void _validateDartDefineProfiles(
  File manifestFile,
  String houseId,
  Map<String, dynamic> manifest,
) {
  final housesDirectory = manifestFile.parent.parent.parent;
  final profiles = housesDirectory.listSync().whereType<File>().where((file) {
    final name = file.uri.pathSegments.last;
    return name.startsWith('$houseId-') && name.endsWith('.json');
  }).toList()..sort((left, right) => left.path.compareTo(right.path));

  // Profiles are local/CI configuration and intentionally git-ignored. Their
  // absence in a clean checkout is valid; every profile that is present must
  // still agree with the tracked broker-house manifest.
  for (final file in profiles) {
    final profilePath = file.path;
    final profile = _readJson(file);
    if (profile == null) continue;

    _expect(
      profile['OMS_HOUSE_ID'] == houseId,
      profilePath,
      'OMS_HOUSE_ID must match manifest houseId',
    );
    _expect(
      profile['OMS_HOUSE_NAME'] == manifest['appName'],
      profilePath,
      'OMS_HOUSE_NAME must match manifest appName',
    );

    final manifestLocales = _asMap(manifest['locales']);
    if (manifestLocales != null) {
      _expect(
        profile['OMS_DEFAULT_LOCALE'] == manifestLocales['default'],
        profilePath,
        'OMS_DEFAULT_LOCALE must match manifest locales.default',
      );
    }

    final filename = file.uri.pathSegments.last;
    final environment = filename.substring(
      houseId.length + 1,
      filename.length - '.json'.length,
    );
    _expect(
      const {'uat', 'prod'}.contains(environment),
      profilePath,
      'profile filename must use the uat or prod environment',
    );
    _expect(
      profile['OMS_ENV'] == environment,
      profilePath,
      'OMS_ENV must match the profile filename environment',
    );

    for (final key in [
      'OMS_BRAND_APP_ICON_ASSET',
      'OMS_BRAND_LOGO_ASSET',
      'OMS_BRAND_DARK_LOGO_ASSET',
      'OMS_BRAND_SPLASH_ASSET',
      'OMS_BRAND_DARK_SPLASH_ASSET',
      'OMS_BRAND_ONBOARDING_FIRST_ASSET',
      'OMS_BRAND_ONBOARDING_SECOND_ASSET',
    ]) {
      _expect(
        _nonEmptyString(profile[key]),
        profilePath,
        '$key must be a path',
      );
    }

    for (final key in [
      'OMS_BRAND_PRIMARY_COLOR',
      'OMS_BRAND_ACCENT_COLOR',
      'OMS_BRAND_BUTTON_COLOR',
    ]) {
      _expect(
        profile[key] is String &&
            RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(profile[key] as String),
        profilePath,
        '$key must be a #RRGGBB color',
      );
    }

    for (final key in [
      'OMS_API_BASE_URL',
      'OMS_API_CHART_BASE_URL',
      'OMS_API_ITCH_BASE_URL',
    ]) {
      _expectUrl(profile[key], profilePath, key, const {'http', 'https'});
    }
    for (final key in [
      'OMS_SOCKET_BASE_URL',
      'OMS_SOCKET_MARKET_URL',
      'OMS_SOCKET_NEWS_URL',
      'OMS_SOCKET_INDEX_URL',
      'OMS_SOCKET_MARKET_DEPTH_URL',
      'OMS_SOCKET_NEWS_TIME_SALES_URL',
    ]) {
      _expectUrl(profile[key], profilePath, key, const {'ws', 'wss'});
    }

    final contractUrl = profile['OMS_CONTRACT_URL'];
    if (contractUrl is String && contractUrl.isNotEmpty) {
      _expectUrl(contractUrl, profilePath, 'OMS_CONTRACT_URL', const {
        'http',
        'https',
      });
    }
  }
}

Map<String, dynamic>? _readJson(File file) {
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map<String, dynamic>) return decoded;
    _errors.add('${file.path}: manifest root must be an object');
  } on FormatException catch (error) {
    _errors.add('${file.path}: invalid JSON (${error.message})');
  } on FileSystemException catch (error) {
    _errors.add('${file.path}: ${error.message}');
  }
  return null;
}

Map<String, String> _readProperties(File file) {
  final values = <String, String>{};
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#') || !trimmed.contains('=')) {
      continue;
    }
    final separator = trimmed.indexOf('=');
    values[trimmed.substring(0, separator).trim()] = trimmed
        .substring(separator + 1)
        .trim();
  }
  return values;
}

Map<String, dynamic>? _asMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;

bool _nonEmptyString(Object? value) =>
    value is String && value.trim().isNotEmpty;

void _expect(bool condition, String path, String message) {
  if (!condition) _errors.add('$path: $message');
}

void _expectUrl(
  Object? value,
  String path,
  String key,
  Set<String> allowedSchemes,
) {
  final uri = value is String ? Uri.tryParse(value) : null;
  _expect(
    uri != null &&
        uri.hasAuthority &&
        allowedSchemes.contains(uri.scheme.toLowerCase()),
    path,
    '$key must be an absolute ${allowedSchemes.join('/')} URL',
  );
}

/// Reads `applicationId` from the app's real Gradle config so the house
/// metadata cannot drift from what is actually shipped.
String? _nativeApplicationId(String appRoot) {
  for (final name in ['build.gradle', 'build.gradle.kts']) {
    final file = File('$appRoot/android/app/$name');
    if (!file.existsSync()) continue;
    final match = RegExp(
      r'''applicationId\s*=?\s*["']([^"']+)["']''',
    ).firstMatch(file.readAsStringSync());
    if (match != null) return match.group(1);
  }
  return null;
}
