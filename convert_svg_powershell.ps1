# PowerShell script to convert SVG to PNG using .NET
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms

function Convert-SvgToPng {
    param(
        [string]$SvgPath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )
    
    try {
        # Read SVG content
        $svgContent = Get-Content $SvgPath -Raw
        
        # Create a temporary HTML file to render SVG
        $tempHtml = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { margin: 0; padding: 0; }
        svg { width: ${Width}px; height: ${Height}px; }
    </style>
</head>
<body>
$svgContent
</body>
</html>
"@
        
        $tempHtmlPath = [System.IO.Path]::GetTempFileName() + ".html"
        $svgContent | Out-File -FilePath $tempHtmlPath -Encoding UTF8
        
        Write-Host "Created temp HTML: $tempHtmlPath"
        Write-Host "Please manually convert using browser or online tool"
        
    } catch {
        Write-Error "Error converting SVG: $_"
    }
}

# Define icon sizes
$androidSizes = @{
    "frontend_app\android\app\src\main\res\mipmap-mdpi\ic_launcher.png" = 48
    "frontend_app\android\app\src\main\res\mipmap-hdpi\ic_launcher.png" = 72
    "frontend_app\android\app\src\main\res\mipmap-xhdpi\ic_launcher.png" = 96
    "frontend_app\android\app\src\main\res\mipmap-xxhdpi\ic_launcher.png" = 144
    "frontend_app\android\app\src\main\res\mipmap-xxxhdpi\ic_launcher.png" = 192
}

$iosSizes = @{
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@1x.png" = 20
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@2x.png" = 40
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-20x20@3x.png" = 60
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@1x.png" = 29
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@2x.png" = 58
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-29x29@3x.png" = 87
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@1x.png" = 40
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@2x.png" = 80
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-40x40@3x.png" = 120
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@2x.png" = 120
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-60x60@3x.png" = 180
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@1x.png" = 76
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-76x76@2x.png" = 152
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-83.5x83.5@2x.png" = 167
    "frontend_app\ios\Runner\Assets.xcassets\AppIcon.appiconset\Icon-App-1024x1024@1x.png" = 1024
}

# Create directories
foreach ($path in $androidSizes.Keys) {
    $dir = Split-Path $path -Parent
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "Created directory: $dir"
    }
}

Write-Host "Directories created. Use an online SVG to PNG converter like:"
Write-Host "1. https://convertio.co/svg-png/"
Write-Host "2. https://cloudconvert.com/svg-to-png"
Write-Host "3. Open convert_icon_simple.html in your browser"
Write-Host ""
Write-Host "Convert tx-app-icon-minimal.svg to the following sizes and place them in the specified locations:"
Write-Host ""
Write-Host "Android Icons:"
foreach ($path in $androidSizes.Keys) {
    $size = $androidSizes[$path]
    Write-Host "  ${size}x${size} -> $path"
}
Write-Host ""
Write-Host "iOS Icons:"
foreach ($path in $iosSizes.Keys) {
    $size = $iosSizes[$path]
    Write-Host "  ${size}x${size} -> $path"
}