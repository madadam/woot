module woot.layout.linear;

import meta.accessor;
import woot.layout.base;
import woot.log;
import woot.widget;

/**
 * Abstract class that lays out the widget in line - either horizontal or vertical.
 **/
class LinearLayout : Layout {
  mixin(accessor!(double, "spacing"));

  override void apply() {
    auto n         = widget.children.length;
    auto dimension = (parentDimension - (n - 1) * spacing) / n;
    auto position  = 0.0;

    foreach(child; widget.children) {
      applyToChild(child, position, dimension);
      position += dimension + spacing;
    }
  }

  protected abstract void applyToChild(Widget child, double position, double dimension);

  @property
  protected abstract double parentDimension();
}
