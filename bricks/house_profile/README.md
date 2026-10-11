# house_profile

Generates local `--dart-define-from-file` profiles, Android flavor metadata, a
branding manifest, and a house asset directory guide. Profiles include endpoint,
asset, and Firebase placeholders; replace them with house configuration before
building. Actual profiles are git-ignored and must be supplied to each developer
or CI environment securely.

The live app consumes display name, logo, splash artwork, onboarding artwork,
default locale, and theme colors from the profile. Contract URL and capability
fields are provided as config; the existing contract page and server-side
authorization remain app/backend responsibilities.

Run from the monorepo root:

```sh
fvm exec mason make house_profile --output-dir apps/benemoy
```

Add the matching `google-services.json` under
`apps/benemoy/android/app/src/<house_id>/` and house-specific assets under
`apps/benemoy/assets/houses/<house_id>/` before building Android.
