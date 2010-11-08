module woot.composite;

import woot.widget;

interface Compositable {
  void add(Widget[] widgets...);
  void remove(Widget[] widgets...);

  @property Widget[] children();
}

mixin template Composite() {
  import std.algorithm;

  void add(Widget[] widgets...) {
    foreach(widget; widgets) {
      _children ~= widget;
    }
  }

  void remove(Widget[] widgets...) {
    // TODO: Optimize, if possible.
    foreach(widget; widgets) {
      auto index = indexOf(_children, widget);

      if (index >= 0) {
        _children = std.algorithm.remove!(SwapStrategy.stable)(_children, index);
      }
    }
  }

  Widget[] children() {
    return _children;
  }

  private Widget[] _children;
}
