# {{display_name}} configuration

- Dart defines: `config/houses/{{house_id}}-uat.json` and
  `config/houses/{{house_id}}-prod.json`
- Android native Firebase file:
  `android/app/src/{{house_id}}/google-services.json`
- Android flavor metadata: `config/houses/android/{{house_id}}.properties`
- Dart brand assets: `assets/houses/{{house_id}}/`
- House branding and capability manifest: `config/houses/brands/{{house_id}}/manifest.json`
- iOS must receive a house-specific bundle ID, Firebase plist, and Xcode
  scheme/configuration before it is released for this house.

The UAT profile selects `.invalid` endpoints and asset paths. Replace every
placeholder, add the referenced assets, and supply house Firebase config before
building. The app consumes the display name, logo, splash, onboarding images,
default locale, and theme colors from Dart defines. `OMS_CONTRACT_URL` is stored
in shared config; the contract page integration remains app-owned.
