## 3.0.0

Rewritten on top of the latest native SuprSend SDKs (`com.suprsend:native` 2.0.1
on Android, `SuprSendSwift` 1.2.0 on iOS). This is a breaking change from the
2.x line.

### Breaking changes

* Initialization now uses a workspace **public key** (and optional JWT user
  token) instead of an api key / api secret pair, via a constructor-style call:
  `SuprSend('public-key')`.
* After initialization, the SDK is accessed through static members on the
  `SuprSend` class (e.g. `SuprSend.identify(...)`, `SuprSend.user.addEmail(...)`).
* User channel methods renamed to match the native SDKs:
  `addEmail` / `removeEmail`, `addSMS` / `removeSMS`,
  `addWhatsapp` / `removeWhatsapp`.
* `unSet` is now `unset`.
* Asynchronous methods now return an `SSResponse` future you can await.

### Added

* `identify(distinctId, userToken:)`, `isIdentified`, `getDistinctId`.
* `track`, full `user` property API (`set`, `setOnce`, `increment`, `append`,
  `remove`, `unset`).
* `user.setPreferredLanguage`, `user.setTimezone`.
* iOS push helpers: `push.registerForPush`, `push.updatePushSubscription`,
  `push.removePushSubscription`.
* Android FCM token registration via `user.setAndroidFcmPush` plus a bundled
  `SSFirebaseMessagingService` manifest entry.
* Typed `SSResponse` results.
* `enableLogging()` turns on verbose native logging (replaces `setLogLevel`).
