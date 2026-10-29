# Watch Studio

## Get the APK (no Flutter install needed)
1. Create a free GitHub repo, upload all these files (keep the .github folder), push to main.
2. Open the repo > Actions > "Build APK" > wait ~5 min.
3. Open the finished run > Artifacts > download watch-studio-apk > unzip > install app-release.apk on your phone.

## Build locally (Windows)
    flutter create . --platforms=android --project-name watch_studio --org com.example
    flutter pub get
    flutter run
    flutter build apk --release
APK: build\app\outputs\flutter-apk\app-release.apk
