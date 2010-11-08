module woot.layout.base;

import woot.window;

class Layout {
  void attach(Window widget) {
    this.widget = widget;
    this.widget.resized.connect(&apply);
  }

  protected abstract void apply();
  protected Window widget;
}
