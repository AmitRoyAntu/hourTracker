# How to Build APK Without Android Studio

## Method 1: Command Line SDK Tools Only

### Step 1: Download Android SDK Tools
1. Go to: https://developer.android.com/studio#command-tools
2. Download "Command line tools only" (much smaller than Android Studio)
3. Extract to: `C:\Android\cmdline-tools`

### Step 2: Set Environment Variables
1. Open System Properties → Advanced → Environment Variables
2. Add new System Variables:
   - `ANDROID_HOME` = `C:\Android`
   - `ANDROID_SDK_ROOT` = `C:\Android`
3. Add to PATH:
   - `C:\Android\cmdline-tools\bin`
   - `C:\Android\platform-tools`

### Step 3: Install Required Components
```bash
sdkmanager "platform-tools" "platforms;android-30" "build-tools;30.0.3"
```

### Step 4: Configure Flutter
```bash
flutter config --android-sdk C:\Android
```

### Step 5: Build APK
```bash
flutter build apk --release
```

## Method 2: GitHub Actions (Free Online Build)

### Step 1: Upload to GitHub
1. Create a GitHub repository
2. Upload your Flutter project

### Step 2: Add Workflow File
Create `.github/workflows/build.yml`:

```yaml
name: Build APK
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.35.3'
    - run: flutter pub get
    - run: flutter build apk --release
    - uses: actions/upload-artifact@v3
      with:
        name: app-release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### Step 3: Download APK
After the workflow runs, download the APK from the Actions tab.

## Method 3: Online APK Builders

### FlutterFlow
1. Go to https://flutterflow.io
2. Import your Flutter project
3. Use their build service

### Codemagic
1. Go to https://codemagic.io
2. Connect your repository
3. Free builds available

## Method 4: APK from Web Build

You can also convert your web build to an APK using tools like:
- TWA (Trusted Web Activity)
- Capacitor
- PWA to APK converters

## Quick Test: Web Version
While setting up SDK, you can test the web version:
```bash
flutter build web
```
Then serve the files from `build/web` folder.
