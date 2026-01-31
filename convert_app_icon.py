import os
from PIL import Image
import cairosvg

def convert_svg_to_png(svg_path, output_path, size):
    """Convert SVG to PNG with specified size"""
    png_data = cairosvg.svg2png(url=svg_path, output_width=size, output_height=size)
    with open(output_path, 'wb') as f:
        f.write(png_data)

def generate_app_icons():
    svg_file = "tx-app-icon-minimal.svg"
    
    # Android icon sizes
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192
    }
    
    # iOS icon sizes
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024
    }
    
    # Generate Android icons
    for folder, size in android_sizes.items():
        android_path = f"frontend_app/android/app/src/main/res/{folder}"
        os.makedirs(android_path, exist_ok=True)
        output_file = os.path.join(android_path, "ic_launcher.png")
        convert_svg_to_png(svg_file, output_file, size)
        print(f"Generated Android icon: {output_file} ({size}x{size})")
    
    # Generate iOS icons
    ios_path = "frontend_app/ios/Runner/Assets.xcassets/AppIcon.appiconset"
    for filename, size in ios_sizes.items():
        output_file = os.path.join(ios_path, filename)
        convert_svg_to_png(svg_file, output_file, size)
        print(f"Generated iOS icon: {output_file} ({size}x{size})")

if __name__ == "__main__":
    generate_app_icons()
    print("App icons generated successfully!")