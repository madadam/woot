module woot.widget;

import meta.attribute;
import woot.color;
import woot.event;
import woot.graphics;
import woot.log;

class Widget {
  Event!() paintRequested;

  mixin(attributeAccessor!(double, "x", "y", "width", "height"));
  mixin(attributeAccessor!(Color, "backgroundColor"));

  @property {
    double[2] position() {
      return [x, y];
    }

    double[2] position(double[2] value) {
      x = value[0];
      y = value[1];

      return value;
    }

    double[2] size() {
      return [width, height];
    }

    double[2] size(double[2] value) {
      width  = value[0];
      height = value[1];

      return value;
    }
  }

  void paint() {
    paintBackground();
    paintRequested();
  }

  protected void paintBackground() {
    glBegin(GL_QUADS);
      glColor4d(backgroundColor.tupleof);
      glVertex2d(0.0,   0.0);
      glVertex2d(width, 0.0);
      glVertex2d(width, height);
      glVertex2d(0.0,   height);
    glEnd();
  }
}
