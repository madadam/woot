module woot.color;

struct Color {
  float red   = 0.0;
  float green = 0.0;
  float blue  = 0.0;
  float alpha = 1.0;

  this(float red, float green, float blue, float alpha = 1.0) {
    this.red   = red;
    this.green = green;
    this.blue  = blue;
    this.alpha = alpha;
  }
}

enum : Color {
  black = Color(0.0, 0.0, 0.0),
  white = Color(1.0, 1.0, 1.0),
  red   = Color(1.0, 0.0, 0.0),
  green = Color(0.0, 1.0, 0.0),
  blue  = Color(0.0, 0.0, 1.0)
}

/// Create color from RGB components.
Color rgb(float red, float green, float blue) {
  return Color(red, green, blue);
}

/// Create color from RGBA components.
Color rgba(float red, float green, float blue, float alpha) {
  return Color(red, green, blue, alpha);
}

// TODO: hsb, cmyk, ...
