// Creates a new broker-house app under apps/<id> from an existing app.
//
//   make new-app ID=fakhrul NAME="Fakhrul Securities" \
//     ANDROID_ID=com.fakhrulsecurities.app IOS_ID=com.fakhrulsecurities.app
//
// Copies the template app's tracked files (never env profiles, signing keys
// or Firebase files), swaps every native identity, and prints what is left
// to fill in.
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final options = _parse(args);
  final id = options['id'];
  final name = options['name'];
  final androidId = options['android-id'];
  final iosId = options['ios-id'];
  final from = options['from'] ?? 'benemoy';

  if (id == null || name == null || androidId == null || iosId == null) {
    _fail(
      'Usage: dart run tool/new_app.dart --id <id> --name "<Display Name>" '
      '--android-id <com.x.app> --ios-id <com.x.app> [--from benemoy]',
    );
  }
  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(id)) {
    _fail('id must be lowercase letters, digits and _ (e.g. fakhrul)');
  }
  final packageId = RegExp(r'^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$');
  if (!packageId.hasMatch(androidId)) {
    _fail('android-id must look like com.company.app');
  }
  if (!RegExp(r'^[A-Za-z][A-Za-z0-9\-]*(\.[A-Za-z0-9\-]+)+$').hasMatch(iosId)) {
    _fail('ios-id must look like com.company.app');
  }

  final source = 'apps/$from';
  final target = 'apps/$id';
  if (!Directory(source).existsSync()) _fail('template app $source not found');
  if (Directory(target).existsSync()) {
    _fail(
      '$target already exists. Remove it first if it is a leftover starter.',
    );
  }

  final sourceAndroidId = _read(
    '$source/android/app/build.gradle',
    r'applicationId\s*=?\s*"([^"]+)"',
  );
  final sourceIosId = _read(
    '$source/ios/Runner.xcodeproj/project.pbxproj',
    r'PRODUCT_BUNDLE_IDENTIFIER = ([A-Za-z0-9.\-]+);',
  );
  final sourceName = _read(
    '$source/android/app/src/main/AndroidManifest.xml',
    r'android:label="([^"]+)"',
  );

  final tracked = Process.runSync('git', ['ls-files', source]);
  if (tracked.exitCode != 0) _fail('git ls-files failed: ${tracked.stderr}');
  const skipped = [
    'android/app/google-services.json',
    'ios/Runner/GoogleService-Info.plist',
    'README.md',
  ];
  var copied = 0;
  for (final path in LineSplitter.split(tracked.stdout as String)) {
    final relative = path.substring(source.length + 1);
    if (skipped.contains(relative) ||
        relative.endsWith('.iml') ||
        relative.contains('/kotlin/') ||
        !File(path).existsSync()) {
      continue;
    }
    final destination = File('$target/$relative')..createSync(recursive: true);
    File(path).copySync(destination.path);
    copied++;
  }

  final quotedName = name.contains(' ') ? '"$name"' : name;
  _edit('$target/pubspec.yaml', [
    (RegExp(r'^name: .*$', multiLine: true), 'name: $id'),
    (
      RegExp(r'^description: .*$', multiLine: true),
      'description: $name trading application.',
    ),
    (RegExp(r'^version: .*$', multiLine: true), 'version: 1.0.0+1'),
  ]);
  _edit('$target/android/app/build.gradle', [
    (RegExp(RegExp.escape('"$sourceAndroidId"')), '"$androidId"'),
  ]);
  _edit('$target/android/app/src/main/AndroidManifest.xml', [
    (
      RegExp('android:label="${RegExp.escape(sourceName)}"'),
      'android:label="$name"',
    ),
  ]);
  _edit('$target/ios/Runner.xcodeproj/project.pbxproj', [
    (RegExp(RegExp.escape(sourceIosId)), iosId),
    (
      RegExp(
        'INFOPLIST_KEY_CFBundleDisplayName = ${RegExp.escape(sourceName)};',
      ),
      'INFOPLIST_KEY_CFBundleDisplayName = $quotedName;',
    ),
  ]);
  // Store release lanes: the new house's ids; its own Apple team.
  for (final file in ['fastlane/Fastfile', 'fastlane/Appfile']) {
    if (!File('$target/$file').existsSync()) continue;
    _edit('$target/$file', [
      (RegExp(RegExp.escape('"$sourceAndroidId"')), '"$androidId"'),
      (RegExp(RegExp.escape('"$sourceIosId"')), '"$iosId"'),
      (
        RegExp(r'(?<=(IOS_TEAM_ID = |team_id\())"[A-Z0-9]+"'),
        '"TODO_TEAM_ID"',
      ),
    ]);
  }
  _edit('$target/ios/Runner/Info.plist', [
    (
      RegExp('<string>${RegExp.escape(sourceName)}</string>'),
      '<string>$name</string>',
    ),
    // Version comes from pubspec.yaml for new apps.
    (
      RegExp(r'(?<=<key>CFBundleShortVersionString</key>\s*<string>)[^<]*'),
      r'$(FLUTTER_BUILD_NAME)',
    ),
  ]);

  final activityDir =
      '$target/android/app/src/main/kotlin/${androidId.replaceAll('.', '/')}';
  File('$activityDir/MainActivity.kt')
    ..createSync(recursive: true)
    ..writeAsStringSync('''package $androidId

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
''');

  File('$target/lib/firebase_options.dart').writeAsStringSync(
    '''// Replace this file: run `flutterfire configure` inside apps/$id.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnimplementedError(
    'Firebase is not configured for $name. Run `flutterfire configure` '
    'in apps/$id.',
  );
}
''',
  );

  File('$target/lib/src/house_profile.dart')
      .writeAsStringSync('''import 'package:oms_shared/oms_shared.dart';

/// Company details shown in the app: contact page, share text, store links.
/// Server URLs, app name and colors live in `env/uat.json` / `env/prod.json`.
const houseProfile = HouseProfile(
  houseId: '$id',
  legalName: 'TODO $name Ltd',
  companyName: '$name',
  contact: HouseContact(
    phone: 'TODO',
    whatsApp: 'TODO',
    email: 'TODO',
    websiteUrl: 'TODO',
    officeAddressShort: 'TODO',
    officeAddressFull: 'TODO',
    tradingHours: 'Sunday - Thursday (10:00 AM - 2:00 PM)',
  ),
  store: HouseStoreListing(
    androidPackageId: '$androidId',
    iosBundleId: '$iosId',
    appStoreId: 'TODO',
    playStoreShareUrl:
        'https://play.google.com/store/apps/details?id=$androidId',
    appStoreShareUrl: 'TODO',
  ),
);
''');

  final example = File('$target/env/example.json');
  final env = jsonDecode(example.readAsStringSync()) as Map<String, dynamic>;
  env['OMS_HOUSE_ID'] = id;
  env['OMS_HOUSE_NAME'] = name;
  example.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(env)}\n',
  );

  File('$target/README.md').writeAsStringSync('''# $name

Broker-house app. All screens and logic come from `packages/`; this folder only
holds what is specific to $name.

| What | Where |
|---|---|
| Server URLs, app name, colors | `env/uat.json`, `env/prod.json` (copy `env/example.json`) |
| Logo, splash, onboarding images | `assets/brand/` |
| Contact page, share text, store ids | `lib/src/house_profile.dart` |
| Screens and routes | `lib/src/routing/app_pages.dart` |
| App id, icons, Firebase, signing | `android/`, `ios/`, `lib/firebase_options.dart` |

Run from the workspace root: `make run APP=$id` (UAT) or `make run APP=$id ENV=prod`.
''');

  _addLaunchConfigs(id, name);

  stdout.writeln('''
Created $target ($copied files from $source).

Still to do before it can run:
  1. cp $target/env/example.json $target/env/uat.json   (and prod.json), then fill in the URLs
  2. Replace the images in $target/assets/brand/ (they are still $sourceName's)
  3. Fill in the TODOs in $target/lib/src/house_profile.dart
  4. cd $target && flutterfire configure   (Firebase project for $androidId / $iosId)
  5. Launcher icons: android/app/src/main/res/mipmap-*, ios/Runner/Assets.xcassets/AppIcon.appiconset
  6. Release signing: $target/android/key.properties + keystore; Apple team in Xcode
  7. Store releases: set TODO_TEAM_ID in $target/fastlane/, add a release
     workflow and secrets for $id (docs/release.md)
  8. fvm dart run melos bootstrap && make check
''');
}

Map<String, String> _parse(List<String> args) {
  final result = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) continue;
    final eq = arg.indexOf('=');
    if (eq > 0) {
      result[arg.substring(2, eq)] = arg.substring(eq + 1);
    } else if (i + 1 < args.length) {
      result[arg.substring(2)] = args[++i];
    }
  }
  return result;
}

String _read(String path, String pattern) {
  final match = RegExp(pattern).firstMatch(File(path).readAsStringSync());
  if (match == null) _fail('could not read $pattern from $path');
  return match.group(1)!;
}

void _edit(String path, List<(RegExp, String)> replacements) {
  final file = File(path);
  var text = file.readAsStringSync();
  for (final (pattern, value) in replacements) {
    if (!pattern.hasMatch(text)) _fail('expected ${pattern.pattern} in $path');
    text = text.replaceAll(pattern, value);
  }
  file.writeAsStringSync(text);
}

void _addLaunchConfigs(String id, String name) {
  final file = File('.vscode/launch.json');
  if (!file.existsSync()) return;
  final launch = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final configs = (launch['configurations'] as List)
      .cast<Map<String, dynamic>>();
  for (final env in ['uat', 'prod']) {
    configs.add({
      'name': '$name ${env.toUpperCase()}',
      'request': 'launch',
      'type': 'dart',
      'cwd': '\${workspaceFolder}/apps/$id',
      'program': '\${workspaceFolder}/apps/$id/lib/main_$env.dart',
      'args': ['--dart-define-from-file=env/$env.json'],
    });
  }
  file.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(launch)}\n',
  );
}

Never _fail(String message) {
  stderr.writeln('new_app: $message');
  exit(1);
}
