Android release checklist (e-pajak)

1) Generate upload keystore (once)

   keytool -genkey -v -keystore upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000

   Move to: android/app/upload-keystore.jks

2) Create key.properties (do not commit)

   Copy android/key.properties.example to android/key.properties and set passwords.

3) Build release App Bundle

   flutter clean && flutter pub get
   flutter build appbundle --release

   Output: build/app/outputs/bundle/release/app-release.aab

4) Play Console

   - Create app “e-pajak”
   - Fill Store Listing, graphics, privacy policy URL
   - Upload AAB to Internal testing and roll out
   - Complete Data Safety, Content rating, target audience
   - Promote to Production (staged rollout recommended)

Notes

 - ApplicationId: id.epajak.app
 - Storage permission removed; relies on system share/save flows
 - Signing is auto-wired via android/app/build.gradle.kts when key.properties exists

