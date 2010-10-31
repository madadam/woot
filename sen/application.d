module sen.application;

public import derelict.opengl.gl;
public import derelict.opengl.glu;
static import backend = sen.backend;
import sen.window;
import std.algorithm;

// Run the application. This will spin the main event loop.
void run() {
  while (running) {
    backend.processEvent();
  }

  closeAllWindows();
}

// Stop the application.
void stop() {
  running = false;
}

private void start() {
  running = true;
}

// New window calls this when created.
package void registerWindow(Window window) {
  if (windows.length <= 0) start();

  windows ~= window;
}

// Window calls this when destroyed.
package void unregisterWindow(Window window) {
  auto index = indexOf(windows, window);

  if (index >= 0) {
    windows = remove!(SwapStrategy.unstable)(windows, index);
  }

  if (windows.length <= 0) stop();
}

private void closeAllWindows() {
  foreach(window; windows) window.close();
}

private bool running = false;
private Window[] windows;

// Load dynamic libs.
static this() {
  DerelictGL.load();
  DerelictGLU.load();
}
