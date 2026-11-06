# Testing on iOS (TestFlight)

TestFlight is free to use, but it needs a paid **Apple Developer Program**
membership ($99/year, developer.apple.com/programs). There is no free way to put
an app on someone else's iPhone or iPad.

The app is already prepared: bundle ID `com.nhson.vocaswiper`, Sunny icon,
`ITSAppUsesNonExemptEncryption = false` (no encryption question on each upload)
and a privacy manifest saying the app collects nothing and tracks nothing.

## One-time setup (owner)

1. **Enroll** in the Apple Developer Program. Approval can take a day or two.
2. **Sign in to Xcode:** Xcode → Settings → Accounts → + → Apple ID.
3. **Pick the team:** open `ios/Runner.xcworkspace`, select the Runner target →
   Signing & Capabilities → Team. Keep "Automatically manage signing" on. Xcode
   registers the bundle ID for you.
4. **Create the app in App Store Connect** (appstoreconnect.apple.com → Apps → +
   → New App): platform iOS, name "Voca Swiper" (if taken, e.g. "Voca Swiper
   Kids"), primary language English, bundle ID `com.nhson.vocaswiper`, SKU
   `vocaswiper`.
5. **Optional, so uploads can be done from the command line:** App Store Connect
   → Users and Access → Integrations → App Store Connect API → generate a key
   with the App Manager role. Save the `.p8` file to
   `~/.appstoreconnect/private_keys/` and note the Key ID and Issuer ID. Never
   commit it.

## Each build

Raise the build number in `pubspec.yaml` (`0.1.0+1` → `0.1.0+2`). App Store
Connect refuses a build number it has already seen.

```bash
flutter build ipa --release
# → build/ios/ipa/voca_swiper.ipa
```

Upload with one of:

- **Transporter** (free Mac App Store app): drag the `.ipa` in, then Deliver.
- **Command line** (with the API key from step 5):
  `xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>`
- **Xcode:** open `build/ios/archive/Runner.xcarchive` → Distribute App →
  TestFlight & App Store.

Processing takes 5–30 minutes. Apple then emails you and the build shows under
TestFlight.

## Testers

- **Internal testers** (people added to your App Store Connect team, up to 100):
  get builds straight away, no review. Best for your own family devices.
- **External testers** (anyone, by email or public link, up to 10,000): the first
  build of each version goes through Beta App Review, usually within a day. You
  fill in a short "What to test" note and a contact email.

Testers install the free **TestFlight** app, accept the invite and tap Install.
Builds expire after 90 days. Progress is stored on the device and kept across
TestFlight updates.
