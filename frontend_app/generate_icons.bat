@echo off
echo Converting SVG to PNG and generating app icons...

REM First, get dependencies
flutter pub get

REM Generate the launcher icons
flutter pub run flutter_launcher_icons

echo.
echo Icon generation complete!
echo.
echo If you see any errors about missing PNG files, please:
echo 1. Convert your SVG file to PNG (1024x1024) using an online converter
echo 2. Save it as assets/logo/app_icon.png
echo 3. Create a foreground version as assets/logo/app_icon_foreground.png
echo 4. Run this script again
echo.
pause