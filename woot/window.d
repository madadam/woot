module woot.window;

import meta.attribute;
import woot.application;
import woot.color;
import woot.composite;
import woot.event;
import woot.graphics;
import woot.widget;

static import woot.backend;

class Window : Compositable {
  Event!() keyPressed;
  Event!() paintRequested;
  Event!() resized;

  mixin Composite;

  this() {
    handle.initialize(this);
    registerWindow(this);

    resized.connect(&setProjection);

    glShadeModel(GL_SMOOTH);
    // glEnable(GL_BLEND);
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    backgroundColor = white;
  }

  ~this() {
    close();
  }

  // visibility

  void show() {
    handle.show();
    resized();
  }

  mixin delegateTo!("handle", "hide");

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

  mixin(attributeReader!(Color, "backgroundColor"));

  @property
  Color backgroundColor(in Color value) {
    _backgroundColor = value;
    glClearColor(value.tupleof);

    // TODO: damage

    return value;
  }

  // geometry

  @property
  int width() {
    return handle.width();
  }

  @property
  int width(int value) {
    return handle.width(value);
  }

  @property
  int height() {
    return handle.height();
  }

  @property
  int height(int value) {
    return handle.height(value);
  }

  // decorations

  mixin delegateTo!("handle", "showDecorations");
  mixin delegateTo!("handle", "hideDecorations");

  // rendering

  void paint() {
    clear();
    paintChildren();
    paintRequested();
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

  private mixin delegateTo!("handle", "swapBuffers");

  private void setProjection() {
    glViewport(0, 0, width, height);

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

  private woot.backend.Window handle;
}

// TODO: make this more robust and extract it into separate library.
private mixin template delegateTo(string target, string name) {
  mixin("void " ~ name ~ "() { " ~ target ~ "." ~ name ~ "(); }");
}
