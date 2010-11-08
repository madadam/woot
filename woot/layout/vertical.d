module woot.layout.vertical;

import woot.layout.linear;
import woot.widget;

class VerticalLayout : LinearLayout {
  override double parentDimension() {
    return widget.height;
  }

  override void applyToChild(Widget child, double position, double dimension) {
    child.x      = 0.0;
    child.y      = position;
    child.width  = widget.width;
    child.height = dimension;
  }
}
