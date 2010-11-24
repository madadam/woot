module woot.window;

import meta.accessor;
import std.algorithm;
import std.math : round;

import woot.application;
import woot.color;
import woot.event;
import woot.layout.container;
import woot.opengl;
import woot.widget;

static import woot.backend;

class Window : Container {
  this() {
    handle.initialize(this);
    registerWindow(this);

    resized.connect(&setProjection);

    glShadeModel(GL_SMOOTH);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    if (glBlendEquationSeparate) {
      glBlendEquationSeparate(GL_FUNC_ADD, GL_MAX);
    }

    backgroundColor = white;
  }

  ~this() {
    close();
  }

  // events
  mixin(event!"keyPressed");
  mixin(event!"paintRequested");
  mixin(event!"resized");

  // visibility

  void show() {
    handle.show();
    resized.trigger();
  }

  mixin(delegateTo!("handle", "hide"));

  // window title

  @property
  string title() {
    return handle.title();
  }

  @property
  string title(string value) {
    return handle.title(value);
  }

  // background

  mixin(getter!(Color, "backgroundColor"));

  @property
  Color backgroundColor(in Color value) {
    _backgroundColor = value;
    glClearColor(value.tupleof);

    // TODO: damage

    return value;
  }

  // geometry

  @property
  double width() {
    return handle.width();
  }

  @property
  double width(double value) {
    return handle.width(value);
  }

  @property
  double height() {
    return handle.height();
  }

  @property
  double height(double value) {
    return handle.height(value);
  }

  // decorations

  mixin(delegateTo!("handle", "showDecorations"));
  mixin(delegateTo!("handle", "hideDecorations"));

  // rendering

  void paint() {
    clear();
    paintChildren();
    paintRequested.trigger();
    swapBuffers();
  }

  private void clear() {
    glClear(GL_COLOR_BUFFER_BIT);
  }

  private void paintChildren() {
    foreach(child; children) {
      glMatrixMode(GL_MODELVIEW);
      glPushMatrix();
      glTranslated(child.x, child.y, 0.0);

      child.paint();

      glPopMatrix();
    }
  }

  private mixin(delegateTo!("handle", "swapBuffers"));

  private void setProjection() {
    glViewport(0, 0, cast(int) round(width), cast(int) round(height));

    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, width, 0.0, height);

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
  }

  // closing

  void requestClose() {
    close();
  }

  void close() {
    unregisterWindow(this);
    handle.destroy();
  }

  // children

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
  private woot.backend.Window handle;
}

// TODO: make this more robust and extract it into separate library.
private pure string delegateTo(string target, string name)() {
  return "void " ~ name ~ "() { " ~ target ~ "." ~ name ~ "(); }";
}
