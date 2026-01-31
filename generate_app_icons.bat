@echo off
echo Generating app icons from tx-app-icon-minimal.svg...

REM Create directories for Android icons
mkdir "frontend_app\android\app\src\main\res\mipmap-mdpi" 2>nul
mkdir "frontend_app\android\app\src\main\res\mipmap-hdpi" 2>nul
mkdir "frontend_app\android\app\src\main\res\mipmap-xhdpi" 2>nul
mkdir "frontend_app\android\app\src\main\res\mipmap-xxhdpi" 2>nul
mkdir "frontend_app\android\app\src\main\res\mipmap-xxxhdpi" 2>nul

echo Created Android directories
echo.
echo Please use the HTML converter (convert_icon_simple.html) to generate PNG files:
echo 1. Open convert_icon_simple.html in your browser
echo 2. Select tx-app-icon-minimal.svg
echo 3. Download all generated PNG files
echo 4. Place them in the correct directories:
echo.
echo Android icons:
echo - ic_launcher_48.png -> frontend_app\android\app\src\main\res\mipmap-mdpi\ic_launcher.png
echo - ic_launcher_72.png -> frontend_app\android\app\src\main\res\mipmap-hdpi\ic_launcher.png
echo - ic_launcher_96.png -> frontend_app\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png
echo - ic_launcher_144.png -> frontend_app\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png
echo - ic_launcher_192.png -> frontend_app\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png
echo.
echo iOS icons (place in frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\):
echo - ios_20.png -> Icon-App-20x20@1x.png
echo - ios_40.png -> Icon-App-20x20@2x.png and Icon-App-40x40@1x.png
echo - ios_60.png -> Icon-App-20x20@3x.png
echo - ios_29.png -> Icon-App-29x29@1x.png
echo - ios_58.png -> Icon-App-29x29@2x.png
echo - ios_87.png -> Icon-App-29x29@3x.png
echo - ios_80.png -> Icon-App-40x40@2x.png
echo - ios_120.png -> Icon-App-40x40@3x.png and Icon-App-60x60@2x.png
echo - ios_180.png -> Icon-App-60x60@3x.png
echo - ios_76.png -> Icon-App-76x76@1x.png
echo - ios_152.png -> Icon-App-76x76@2x.png
echo - ios_167.png -> Icon-App-83.5x83.5@2x.png
echo - ios_1024.png -> Icon-App-1024x1024@1x.png

pause