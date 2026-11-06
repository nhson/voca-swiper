# Testing on Android (free)

Voca Swiper is not on Google Play yet. Testers install it from an APK file.

## Build the APK

```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

Release builds are signed with the upload key named in `android/key.properties`
(git-ignored; the keystore itself lives outside the repo). Without that file the
build falls back to the debug key, and testers would have to uninstall (losing
progress) before they could install a properly signed build.

**Back up the keystore and `key.properties` somewhere safe.** Every update must be
signed with the same key, or Android refuses to install it over the old one.

Before each new build for testers, raise the version in `pubspec.yaml`
(`version: 0.1.0+1` → `0.1.1+2`): the number after `+` must go up, or the update
will not install over the previous one.

## Share it

Pick one:

- **Direct:** send the APK (Google Drive, a USB cable, a messaging app). On the
  phone, open it and allow "Install unknown apps" for the app you opened it from.
- **Firebase App Distribution (free):** create a Firebase project, open
  App Distribution, add the Android app with package name `com.nhson.vocaswiper`,
  upload the APK and invite testers by email. They install through the Firebase
  App Tester app and are told about new builds. No Firebase code goes into the
  app.

## What testers keep

All progress is stored on the device. Updating the app keeps it; uninstalling
deletes it. The app needs no internet connection and asks only for permission to
show reminders.

## App icon

The icon is Sunny drawn in code. To redraw it after changing the mascot:

```bash
flutter test tool/make_icon_test.dart && tool/make_icons.sh
```
