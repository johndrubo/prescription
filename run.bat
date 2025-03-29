@echo off
echo Building and installing prescription_scanner...

REM Clean the build
flutter clean

REM Get dependencies
flutter pub get

REM Build the debug APK
flutter build apk --debug

REM Check if the APK was generated
if exist "android\app\build\outputs\apk\debug\app-debug.apk" (
  echo APK built successfully, installing...
  flutter install --use-application-binary=android\app\build\outputs\apk\debug\app-debug.apk
  echo App installed! You can now open it on your device.
) else (
  echo Failed to build APK.
  exit /b 1
)

echo Done! 