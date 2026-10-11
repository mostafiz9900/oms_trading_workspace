# broker_config

Shared compile-time configuration for OMS broker-house identity and endpoints.
Provide house-specific values through `--dart-define-from-file`; app dotenv
values remain available as a migration fallback for API endpoints.

Branding defines include `OMS_BRAND_APP_ICON_ASSET`, `OMS_BRAND_LOGO_ASSET`,
`OMS_BRAND_DARK_LOGO_ASSET`, `OMS_BRAND_SPLASH_ASSET`,
`OMS_BRAND_DARK_SPLASH_ASSET`, `OMS_BRAND_ONBOARDING_FIRST_ASSET`, and
`OMS_BRAND_ONBOARDING_SECOND_ASSET`. The config also supports
`OMS_DEFAULT_LOCALE`, `OMS_BRAND_PRIMARY_COLOR`, `OMS_BRAND_ACCENT_COLOR`,
`OMS_BRAND_BUTTON_COLOR`, and optional `OMS_CONTRACT_URL`.
