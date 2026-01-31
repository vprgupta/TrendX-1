from PIL import Image, ImageDraw

# Create a simple 32x32 PNG icon
img = Image.new('RGBA', (32, 32), (0, 0, 0, 0))
draw = ImageDraw.Draw(img)

# Draw a simple chart-like icon
draw.rectangle([4, 20, 8, 28], fill=(0, 123, 255, 255))  # Blue bar
draw.rectangle([12, 15, 16, 28], fill=(40, 167, 69, 255))  # Green bar
draw.rectangle([20, 10, 24, 28], fill=(255, 193, 7, 255))  # Yellow bar

# Save as PNG
img.save('icon.png')
print("Icon created: icon.png")