from PIL import Image, ImageDraw
import os

# Create the required PNG files from a simple design
def create_app_icon():
    # Create 1024x1024 icon
    img = Image.new('RGBA', (1024, 1024), (15, 23, 42, 255))  # Dark background
    draw = ImageDraw.Draw(img)
    
    # Draw TrendX logo elements
    # Main circle
    center = 512
    radius = 300
    draw.ellipse([center-radius, center-radius, center+radius, center+radius], 
                fill=(59, 130, 246, 255), outline=(147, 197, 253, 255), width=20)
    
    # Trend arrow
    arrow_points = [
        (center-150, center+50),
        (center-50, center-50),
        (center+50, center-100),
        (center+150, center-150),
        (center+100, center-200),
        (center+200, center-250),
        (center+150, center-200),
        (center+50, center-150),
        (center-50, center-100),
        (center-150, center)
    ]
    draw.polygon(arrow_points, fill=(34, 197, 94, 255))
    
    # Save main icon
    os.makedirs('assets/logo', exist_ok=True)
    img.save('assets/logo/app_icon.png')
    
    # Create foreground version (transparent background)
    img_fg = Image.new('RGBA', (1024, 1024), (0, 0, 0, 0))
    draw_fg = ImageDraw.Draw(img_fg)
    
    # Same elements but on transparent background
    draw_fg.ellipse([center-radius, center-radius, center+radius, center+radius], 
                   fill=(59, 130, 246, 255), outline=(147, 197, 253, 255), width=20)
    draw_fg.polygon(arrow_points, fill=(34, 197, 94, 255))
    
    img_fg.save('assets/logo/app_icon_foreground.png')
    
    print("App icons created successfully!")
    print("- assets/logo/app_icon.png")
    print("- assets/logo/app_icon_foreground.png")

if __name__ == "__main__":
    create_app_icon()