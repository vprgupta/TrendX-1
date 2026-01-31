---
name: flutter-ui-design
description: Create distinctive, production-grade Flutter interfaces with exceptional design quality. Use this skill when building Flutter components, screens, or applications requiring polished UI/UX and refined visual identity. Produces creative, performant Flutter code that avoids generic UI aesthetics.
license: Complete terms in LICENSE.txt
---

Below is a **Flutter-specific adaptation** of the provided frontend design skill, rewritten to guide creation of distinctive, production-grade Flutter interfaces across mobile, desktop, and web while preserving the intent and structure but aligning with Flutter’s architecture and tooling.


This skill guides creation of **distinctive, production-grade Flutter interfaces** that avoid generic app aesthetics. Implement real working Flutter code with exceptional attention to visual, motion, and interaction design.

The user provides Flutter requirements: a widget, screen, feature, or full application UI. Context may include platform targets, audience, or technical constraints.

---

## Design Thinking (Flutter Context)

Before coding, understand context and commit to a **bold aesthetic direction**:

### Purpose

* What task or workflow does the interface serve?
* Who is the user?
* What environment is the app used in?

### Tone

Choose a strong design identity:

* Brutalist minimal
* Retro-futuristic
* Luxury editorial
* Playful toy-like
* Industrial/utilitarian
* Organic/natural
* High-tech cyber
* Soft pastel
* Geometric modern
* Experimental layouts

Commit fully to the aesthetic.

### Constraints

Respect Flutter realities:

* Target platforms (Android, iOS, Web, Desktop)
* Performance on low-end devices
* Accessibility requirements
* Responsiveness
* Touch vs pointer interaction
* App lifecycle and navigation patterns

### Differentiation

Define what users will remember:

* Unique motion language?
* Signature layout composition?
* Distinct color identity?
* Interaction style?
* Typography personality?

**Critical rule:** Execute one conceptual direction with precision rather than mixing styles.

---

## Flutter Implementation Principles

Implement working Flutter code that is:

* Production-ready
* Performant
* Visually striking
* Cohesive in identity
* Carefully refined

Prefer clean widget composition and reusable components.

---

## Flutter UI Aesthetic Guidelines

### 1. Typography

Avoid default typography.

Use:

* Custom fonts via `pubspec.yaml`
* Distinct display + body font pairing
* Consistent scale hierarchy
* Strong weight contrast
* Intentional letter spacing

Use Flutter typography theming:

* `ThemeData.textTheme`
* Responsive font scaling
* Platform-aware text rendering

Typography should define character, not just readability.

---

### 2. Color & Theme

Commit to strong color direction.

Best practices:

* Use centralized theme configuration
* Use color tokens and constants
* Support dark/light when appropriate
* Avoid flat default palettes

Use:

* `ColorScheme`
* `ThemeData`
* dynamic theming
* custom gradients
* layered color surfaces

Dominant palette + accent beats evenly distributed color usage.

---

### 3. Motion & Interaction

Flutter excels at motion — use it intentionally.

Prefer:

* Hero transitions
* AnimatedContainer
* AnimatedOpacity
* AnimatedPositioned
* TweenAnimationBuilder
* Custom AnimationController flows
* Page transitions
* Gesture-driven animations

Guidelines:

* Focus on meaningful motion moments
* Use entrance choreography
* Use scroll-based animation
* Avoid excessive micro animations
* Maintain 60fps performance

Motion should guide attention, not distract.

---

### 4. Spatial Composition

Avoid generic app layouts.

Explore:

* Overlapping layers
* Asymmetry
* Floating elements
* Negative space control
* Depth layering
* Diagonal or curved flows

Use:

* Stack
* Positioned
* Custom layout widgets
* Sliver layouts
* CustomScrollView
* Transform
* ClipPath
* CustomPainter

Layouts should feel composed, not assembled.

---

### 5. Backgrounds & Surface Design

Avoid flat surfaces.

Enhance depth via:

* Gradients
* Layered transparencies
* Blur effects (`BackdropFilter`)
* Noise textures
* Custom shapes
* Shadows and elevation control
* Glassmorphism or material blending
* Decorative overlays

Flutter supports GPU acceleration — use it creatively but responsibly.

---

### 6. Component Craftsmanship

Widgets must feel deliberate:

* Buttons feel tactile
* Inputs feel responsive
* Cards feel weighted
* Navigation feels fluid

Refine:

* Padding
* Hit areas
* Touch feedback
* Shadow depth
* Shape language
* State transitions

---

### 7. Responsiveness

Flutter apps run everywhere.

Design for:

* Small phones
* Large phones
* Tablets
* Desktop
* Web layouts

Use:

* LayoutBuilder
* MediaQuery
* Breakpoints
* Adaptive layouts

Avoid mobile-only thinking.

---

### 8. Performance Discipline

Design must not degrade performance.

Avoid:

* Excessive rebuilds
* Heavy nested layouts
* Unnecessary opacity layers
* Unoptimized animations

Use:

* const widgets
* widget splitting
* caching strategies
* efficient scrolling lists

Beauty must remain smooth.

---

## Anti-Patterns to Avoid

Avoid generic UI patterns:

* Default Material layouts everywhere
* Predictable card stacks
* Stock scaffold structures
* Generic gradients
* Unstyled navigation bars
* Overused fonts
* Safe template aesthetics

Every design should feel intentional.

---

## Complexity Matching Rule

Match code complexity to aesthetic:

* Minimal design → precision & restraint
* Maximal design → richer motion & layering
* Experimental UI → custom rendering & animation

Elegance comes from consistency.

---

## Final Principle

A Flutter interface should feel **designed**, not assembled from widgets.

Flutter is capable of extraordinary visuals and interactions — use its capabilities fully and intentionally.
