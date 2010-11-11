module woot.layout.container;

import woot.event;
import woot.widget;

interface Container {
  void add(Widget[] widgets...);
  void remove(Widget[] widgets...);

  @property Widget[] children();

  @property double width();
  @property double height();

  @property ref Event!() resized();
}
