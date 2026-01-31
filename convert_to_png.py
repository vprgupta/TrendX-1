from PIL import Image
import cairosvg
import os

def convert_svg_to_png(svg_path, output_dir):
    """Convert SVG to PNG in multiple sizes for app icons"""
    
    # Create output directory if it doesn't exist
    os.makedirs(output_dir, exist_ok=True)
    
    # Icon sizes needed for different platforms
    sizes = [
        # Android sizes
        (48, 'mdpi'),
        (72, 'hdpi'), 
        (96, 'xhdpi'),
        (144, 'xxhdpi'),
        (192, 'xxxhdpi'),
        # iOS sizes
        (20, '20pt'),
        (29, '29pt'),
        (40, '40pt'),
        (58, '58pt'),
        (60, '60pt'),
        (76, '76pt'),
        (80, '80pt'),
        (87, '87pt'),
        (120, '120pt'),
        (152, '152pt'),
        (167, '167pt'),
        (180, '180pt'),
        (1024, '1024pt'),
        # Common sizes
        (512, '512px'),
        (256, '256px'),
        (128, '128px'),
        (64, '64px'),
        (32, '32px'),
        (16, '16px')
    ]
    
    print(f"Converting {svg_path} to PNG...")
    
    for size, label in sizes:
        try:
            # Convert SVG to PNG using cairosvg
            png_data = cairosvg.svg2png(
                url=svg_path,
                output_width=size,
                output_height=size
            )
            
            # Save PNG file
            output_path = os.path.join(output_dir, f'app_icon_{size}x{size}.png')
            with open(output_path, 'wb') as f:
                f.write(png_data)
            
            print(f"✓ Created {size}x{size} icon")
            
        except Exception as e:
            print(f"✗ Failed to create {size}x{size} icon: {e}")
    
    # Create a main app icon (512x512)
    try:
        png_data = cairosvg.svg2png(
            url=svg_path,
            output_width=512,
            output_height=512
        )
        
        main_icon_path = os.path.join(output_dir, 'app_icon.png')
        with open(main_icon_path, 'wb') as f:
            f.write(png_data)
        
        print(f"✓ Created main app icon: {main_icon_path}")
        
    except Exception as e:
        print(f"✗ Failed to create main app icon: {e}")

if __name__ == "__main__":
    svg_file = "tx-app-icon.svg"
    output_directory = "app_icons"
    
    if os.path.exists(svg_file):
        convert_svg_to_png(svg_file, output_directory)
        print(f"\n🎉 App icons generated in '{output_directory}' folder!")
        print("You can now use these PNG files as your app icons.")
    else:
        print(f"❌ SVG file '{svg_file}' not found!")