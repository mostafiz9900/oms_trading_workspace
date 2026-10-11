// Preserve the legacy app import path while the auth response DTO lives in auth.
export 'package:auth/auth.dart'
    show UserProfile, Token, UserDetail, userProfileFromJson, userProfileToJson;
