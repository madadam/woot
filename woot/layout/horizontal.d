module woot.layout.horizontal;

import woot.layout.linear;
import woot.widget;

class HorizontalLayout : LinearLayout {
  override double parentDimension() {
    return widget.width;
  }

  override void applyToChild(Widget child, double position, double dimension) {
    child.x      = position;
    child.y      = 0.0;
    child.width  = dimension;
    child.height = widget.height;
  }
}
