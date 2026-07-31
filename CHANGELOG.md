# Changelog

## 3.0.0

First release of v3, rewritten on top of the latest native SuprSend Android and
iOS SDKs. This version has breaking changes — refer the
[migration guide](doc/MIGRATION_FROM_V2.md) to upgrade from v2.

- Authentication changed from workspace key + secret to public API key and signed
  user token (`SuprSend.identify(distinctId, userToken: jwt)`), with
  `refreshUserToken` callback support.
- SDK is now initialized from Dart in `main` instead of `SSApi.init` (Android)
  and `SuprSendSDKConfiguration` (iOS).
- Renamed the `suprsend` class to `SuprSend`, exported from a single
  `suprsend_flutter_sdk.dart` library.
- All methods are now awaitable and return `SSResponse` with status, status code
  and error details.
- Added multi-tenant support: `tenantId` in `identify` and `SuprSend.changeTenant`.
- Added `isIdentified`, `getDistinctId`, `enableLogging`, `user.setPreferredLanguage`
  and `user.setTimezone`.
- Renamed user channel methods to `add*` / `remove*` (`addEmail`, `removeEmail`,
  `addSMS`, `removeSMS`, `addWhatsapp`, `removeWhatsapp`) and push methods to
  `user.addPush` / `user.removePush`.
- Removed `purchaseMade`, `setSuperProperties`, `unSetSuperProperty`, `flush`,
  `setLogLevel`, `LogLevels` and `showNotification`.
- Minimum supported versions are now iOS 15.0 and Android `minSdk` 19.
