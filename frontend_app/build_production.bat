@echo off
echo Starting Production Build for TrendX Application...
echo.

echo 1. Cleaning project...
call flutter clean

echo.
echo 2. Getting dependencies...
call flutter pub get

echo.
echo 3. Building Android App Bundle (AAB)...
call flutter build appbundle --release

echo.
echo Build complete. The AAB file can be found in:
echo build\app\outputs\bundle\release\app-release.aab
echo.
echo Note: This AAB is signed with the default debug key or your configured release key in build.gradle. To sign with a specific production keystore, ensure you have set up 'key.properties' as per Flutter documentation.
pause
