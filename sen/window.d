module sen.window;

import sen.application;
static import sen.backend;

class Window {
  this() {
    handle.initialize(this);
    registerWindow(this);

    glShadeModel(GL_SMOOTH);
    // glEnable(GL_BLEND);
    // glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    backgroundColor = [1.0, 1.0, 1.0, 1.0];
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

  @property
  float[4] backgroundColor(float[4] value) {
    _backgroundColor = value;

    // TODO: value.tupleof would be handy here, sadly, does not work with arrays.
    glClearColor(value[0], value[1], value[2], value[3]);

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

  void requestPaint() {
    paint();
  }

  private void paint() {
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    glBegin(GL_TRIANGLES);
      glColor4f(1.0, 0.0, 0.0, 0.1);
      glVertex2f(0.1, 0.1);

      glColor4f(0.0, 1.0, 0.0, 0.1);
      glVertex2f(0.9, 0.1);

      glColor4f(0.0, 0.0, 1.0, 0.1);
      glVertex2f(0.5, 0.9);
    glEnd();

    swapBuffers();
  }

  private mixin delegateTo!("handle", "swapBuffers");

  // event handlers

  void resized() {
    glViewport(0, 0, width, height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, 1.0, 0.0, 1.0);
    glMatrixMode(GL_MODELVIEW);
  }

  void keyPressed() {
    close();
  }

  // closing

  void requestClose() {
    close();
  }

  void close() {
    unregisterWindow(this);
    handle.destroy();
  }

  private float[4] _backgroundColor;

  private sen.backend.Window handle;
}

// TODO: make this more robust and extract it into separate library.
private mixin template delegateTo(string target, string name) {
  mixin("void " ~ name ~ "() { " ~ target ~ "." ~ name ~ "(); }");
}
