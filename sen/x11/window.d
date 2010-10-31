module sen.x11.window;

import sen.x11.backend;
import sen.x11.helpers;
import std.exception;

struct Window {
  void initialize(sen.window.Window window) {
    auto screen = DefaultScreen(display);

    // Select GL visual.
    int[] visualAttributes = [GLX_RGBA,
                              GLX_DOUBLEBUFFER,
                              GLX_RED_SIZE,     8,
                              GLX_GREEN_SIZE,   8,
                              GLX_BLUE_SIZE,    8,
                              GLX_ALPHA_SIZE,   8,
                              // GLX_DEPTH_SIZE,   16,
                              None];

    auto visualInfo = glXChooseVisual(display, screen, visualAttributes.ptr);
    enforce(visualInfo, "No suitable GL visual found.");

    // Create GL context.
    context = glXCreateContext(display, visualInfo, null, true);
    enforce(context, "Failed to create GL context.");

    auto rootWindow = RootWindow(display, visualInfo.screen);

    // Create the window.
    colormap = XCreateColormap(display, rootWindow, visualInfo.visual, AllocNone);

    XSetWindowAttributes windowAttributes;
    windowAttributes.colormap     = colormap;
    windowAttributes.border_pixel = 0;
    windowAttributes.event_mask   = ExposureMask
                                  | KeyPressMask
                                  | KeyReleaseMask
                                  | StructureNotifyMask;

    auto windowAttributesMask = CWBorderPixel | CWColormap | CWEventMask;

    handle = XCreateWindow(display, rootWindow,
                           0, 0, 100u, 100u, // x, y, width, height
                           0u, visualInfo.depth, InputOutput,
                           visualInfo.visual,
                           windowAttributesMask, &windowAttributes);
    enforce(handle, "Failed to create window.");

    // Save pointer to the containing sen window inside the X window,
    // so the event handlers can be called.
    setWindowProperty(handle, _THIS, &window);

    // Notify about window deletion.
    XSetWMProtocols(display, handle, &_WM_DELETE_WINDOW, 1);

    glXMakeCurrent(display, handle, context);
  }

  void destroy() {
    if (handle) {
      XDeleteProperty(display, handle, _THIS);

      if (context) {
        glXMakeCurrent(display, None, null);
        glXDestroyContext(display, context);
      }

      XDestroyWindow(display, handle);
      XFreeColormap(display, colormap);

      handle = 0;
    }
  }

  void swapBuffers() {
    glXSwapBuffers(display, handle);
  }

  void show() {
    XMapWindow(display, handle);
  }

  void hide() {
    XUnmapWindow(display, handle);
  }

  private xlib.Window    handle;
  private xlib.Colormap  colormap;
  private glx.GLXContext context;
}
