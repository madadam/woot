module sen.window;

import sen.application;
static import sen.backend;

class Window {
  this() {
    handle.initialize(this);
    registerWindow(this);

    glShadeModel(GL_SMOOTH);
    glClearColor(0.0, 0.0, 0.0, 0.0);
  }

  ~this() {
    close();
  }

  void show() {
    handle.show();
  }

  void hide() {
    handle.hide();
  }

  @property
  string title() {
    return "";
  }

  @property
  string title(string value) {
    return "";
  }

  void requestPaint() {
    paint();
  }

  void paint() {
    glClear(GL_COLOR_BUFFER_BIT);
    glLoadIdentity();
    glBegin(GL_TRIANGLES);
      glVertex2f(10.0, 10.0);
      glVertex2f(90.0, 10.0);
      glVertex2f(50.0, 90.0);
    glEnd();

    swapBuffers();
  }

  void swapBuffers() {
    handle.swapBuffers();
  }

  void resize() {
    glViewport(0, 0, 100, 100);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluOrtho2D(0.0, 100.0, 0.0, 100.0);
    glMatrixMode(GL_MODELVIEW);
  }

  void requestClose() {
    close();
  }

  void keyPressed() {
    close();
  }

  void close() {
    unregisterWindow(this);
    handle.destroy();
  }

  private sen.backend.Window handle;
}
