module woot.layout.base;

import woot.layout.container;

class Layout {
  void attach(Container widget) {
    this.widget = widget;
    this.widget.resized.connect(&apply);
  }

  protected abstract void apply();
  protected Container widget;
}
