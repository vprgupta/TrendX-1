# 🎨 TrendX Logo & Splash Screen Design Prompts

## 📱 **Mobile Logo Design Prompt**

### **Primary Logo Prompt**
```
Create a modern, minimalist logo for "TrendX" - a social media trend analysis platform:

DESIGN REQUIREMENTS:
- Text: "TrendX" with stylized "X" 
- Style: Modern, tech-focused, clean lines
- Colors: Gradient from electric blue (#00D4FF) to purple (#8B5CF6)
- Icon: Abstract upward trending arrow integrated with the "X"
- Format: Vector-based, scalable from 16px to 512px
- Mobile-optimized: Clear visibility on small screens
- Background: Transparent for versatility

VISUAL ELEMENTS:
- The "X" should incorporate trending/growth symbolism
- Subtle data visualization elements (dots, lines, charts)
- Modern typography - sans-serif, bold but readable
- Gradient effect that suggests movement and growth
- Optional: Small sparkle/pulse effects around the logo

TECHNICAL SPECS:
- Primary: 512x512px PNG with transparency
- Secondary: 256x256px, 128x128px, 64x64px, 32x32px
- SVG format for infinite scalability
- Dark mode variant with white/light colors
- Monochrome version for single-color applications

INSPIRATION KEYWORDS:
Analytics, trending, social media, data visualization, growth, modern tech, mobile-first, professional yet approachable
```

### **App Icon Variant Prompt**
```
Create a simplified app icon version of the TrendX logo:

REQUIREMENTS:
- Square format (1024x1024px for iOS, 512x512px for Android)
- Simplified design that works at 60x60px and smaller
- Bold, recognizable shape
- Same color scheme: blue to purple gradient
- Minimal text or text-free version focusing on the "X" symbol
- High contrast for visibility
- Rounded corners compatible with iOS/Android standards

DESIGN FOCUS:
- The "X" as the primary visual element
- Upward trending arrow integrated into the X
- Clean background (solid color or subtle gradient)
- Ensure legibility on both light and dark backgrounds
```

---

## 🌟 **Splash Screen Design Prompt**

### **Mobile Splash Screen Prompt**
```
Design an engaging splash screen for TrendX mobile app:

LAYOUT REQUIREMENTS:
- Vertical mobile orientation (9:16 aspect ratio)
- Resolution: 1080x1920px (scales to all devices)
- Safe area considerations for notches and navigation bars
- Loading animation area at bottom

VISUAL ELEMENTS:
1. BACKGROUND:
   - Subtle gradient from dark blue (#0F172A) to deep purple (#1E1B4B)
   - Animated particle effects suggesting data flow
   - Subtle grid pattern overlay (low opacity)

2. MAIN LOGO:
   - TrendX logo centered, larger size (200x200px)
   - Gentle pulse/glow animation
   - Fade-in effect on app launch

3. TAGLINE:
   - "Discover What's Trending" below logo
   - Modern, clean font (Poppins or similar)
   - White text with subtle glow effect
   - Fade-in animation after logo appears

4. LOADING INDICATOR:
   - Bottom 20% of screen
   - Animated progress bar with gradient colors
   - Small trending icons (📈 ⚡ 🔥) floating animation
   - "Loading trends..." text

5. ADDITIONAL ELEMENTS:
   - Subtle social media icons floating in background
   - Data visualization elements (charts, graphs) as background
   - Version number in bottom corner (small, low opacity)

ANIMATION SEQUENCE:
1. Background gradient fades in (0.5s)
2. Logo scales in with bounce effect (0.8s)
3. Tagline fades in (0.3s)
4. Loading bar appears and animates (ongoing)
5. Background particles start moving
6. Total splash duration: 2-3 seconds
```

### **Alternative Minimal Splash Screen**
```
Create a clean, minimal splash screen variant:

DESIGN:
- Pure white or dark background (theme-dependent)
- Large TrendX logo in center
- Simple loading spinner below
- "TrendX" wordmark
- Minimal animation: gentle logo fade-in + spinner rotation
- Professional, fast-loading design
- Perfect for users who prefer minimal interfaces
```

---

## 🎯 **Brand Guidelines for Designers**

### **Color Palette**
```
PRIMARY COLORS:
- Electric Blue: #00D4FF
- Purple: #8B5CF6
- Deep Blue: #0F172A
- Dark Purple: #1E1B4B

SECONDARY COLORS:
- White: #FFFFFF
- Light Gray: #F8FAFC
- Medium Gray: #64748B
- Dark Gray: #1E293B

ACCENT COLORS:
- Success Green: #10B981
- Warning Orange: #F59E0B
- Error Red: #EF4444
```

### **Typography**
```
PRIMARY FONT: Poppins (Google Fonts)
- Logo: Poppins Bold (700)
- Headings: Poppins SemiBold (600)
- Body: Poppins Regular (400)

FALLBACK FONTS:
- iOS: SF Pro Display
- Android: Roboto
- Web: Inter, system-ui
```

### **Logo Usage Guidelines**
```
DO:
✅ Use on solid backgrounds with good contrast
✅ Maintain minimum size of 32px for mobile
✅ Use official color versions when possible
✅ Ensure clear space around logo (minimum 16px)

DON'T:
❌ Stretch or distort the logo
❌ Use on busy backgrounds without backdrop
❌ Change colors outside brand palette
❌ Use pixelated or low-resolution versions
```

---

## 📐 **Technical Specifications**

### **Mobile App Requirements**
```
iOS:
- App Icon: 1024x1024px PNG
- Launch Screen: 1125x2436px (iPhone X+)
- Notification Icon: 60x60px, 40x40px, 20x20px

Android:
- App Icon: 512x512px PNG
- Adaptive Icon: 108x108dp with 72x72dp safe zone
- Splash Screen: 1080x1920px
- Notification Icons: 24dp, 18dp, 16dp (vector)

Universal:
- Favicon: 32x32px, 16x16px ICO
- Social Media: 1200x630px PNG
- Print: Vector SVG or high-res PNG (300 DPI)
```

### **File Deliverables**
```
LOGO PACKAGE:
📁 logo-primary.svg (vector)
📁 logo-primary.png (512x512px)
📁 logo-white.svg (dark backgrounds)
📁 logo-monochrome.svg (single color)
📁 app-icon-ios.png (1024x1024px)
📁 app-icon-android.png (512x512px)

SPLASH SCREEN PACKAGE:
📁 splash-screen-light.png (1080x1920px)
📁 splash-screen-dark.png (1080x1920px)
📁 splash-minimal-light.png (1080x1920px)
📁 splash-minimal-dark.png (1080x1920px)

BRAND ASSETS:
📁 brand-guidelines.pdf
📁 color-palette.ase (Adobe Swatch)
📁 typography-guide.pdf
```

---

## 🚀 **Implementation Notes**

### **For Developers**
```dart
// Flutter implementation example
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _textController;
  
  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigateToHome();
  }
  
  void _initAnimations() {
    _logoController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _logoController.forward().then((_) {
      _textController.forward();
    });
  }
  
  void _navigateToHome() {
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    });
  }
}
```

### **Design Tools Recommended**
- **Vector Design**: Figma, Adobe Illustrator, Sketch
- **Animation**: After Effects, Lottie, Figma
- **Optimization**: TinyPNG, SVGO, ImageOptim
- **Testing**: Device simulators, real device testing

---

*Use these prompts with AI design tools like Midjourney, DALL-E, or provide them to human designers for consistent, professional results.*