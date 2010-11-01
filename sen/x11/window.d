module sen.x11.window;

import sen.log;
import sen.x11.backend;
import sen.x11.helpers;
import std.exception;

struct Window {
  void initialize(sen.window.Window window) {
    checkXRenderExtension();

    auto visualInfo = findVisual();
    auto rootWindow = RootWindow(display, visualInfo.screen);

    // Create GL context.
    context = glXCreateContext(display, visualInfo, null, true);
    enforce(context, "Failed to create GL context.");


    // Create the window.
    colormap = XCreateColormap(display, rootWindow, visualInfo.visual, AllocNone);

    XSetWindowAttributes windowAttributes;
    windowAttributes.colormap         = colormap;
    windowAttributes.background_pixel = 0;
    windowAttributes.border_pixel     = 0;
    windowAttributes.event_mask       = ExposureMask
                                      | KeyPressMask
                                      | KeyReleaseMask
                                      | StructureNotifyMask;

    auto windowAttributesMask = CWBackPixel | CWBorderPixel | CWColormap | CWEventMask;

    handle = XCreateWindow(display, rootWindow,
                           0, 0, 640u, 360u, // x, y, width, height
                           0u, visualInfo.depth, InputOutput,
                           visualInfo.visual,
                           windowAttributesMask, &windowAttributes);
    enforce(handle, "Failed to create window.");

    // Save pointer to the containing window inside the X window,
    // so the event handlers can be called.
    setWindowProperty(handle, THIS, &window);

    // Notify about window deletion.
    XSetWMProtocols(display, handle, &WM_DELETE_WINDOW, 1);

    glXMakeCurrent(display, handle, context);
  }

  void destroy() {
    if (handle) {
      XDeleteProperty(display, handle, THIS);

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

  // visibility

  void show() {
    XMapWindow(display, handle);
  }

  void hide() {
    XUnmapWindow(display, handle);
  }

  // geometry

  @property
  int width() {
    return geometry[2];
  }

  @property
  int width(int value) {
    XWindowChanges changes;
    changes.width = value;

    XConfigureWindow(display, handle, CWWidth, &changes);
    return value;
  }

  @property
  int height() {
    return geometry[3];
  }

  @property
  int height(int value) {
    XWindowChanges changes;
    changes.height = value;

    XConfigureWindow(display, handle, CWHeight, &changes);
    return value;
  }

  @property
  int[2] size() {
    auto geometry = this.geometry;
    return [geometry[2], geometry[3]];
  }

  @property
  int[4] geometry() {
    xlib.Window ignoredRoot;
    uint        ignoredStuff;
    int[4]      result;

    XGetGeometry(display, handle, &ignoredRoot,
                 &result[0], &result[1], cast(uint*) &result[2], cast(uint*) &result[3],
                 &ignoredStuff, &ignoredStuff);

    return result;
  }

  // title

  @property
  string title() {
    return getWindowProperty!string(handle, NET_WM_NAME);
  }

  @property
  string title(string value) {
    setWindowProperty(handle, NET_WM_NAME, value);
    return value;
  }

  // decorations

  void showDecorations() {
    setMotifWmHints([2, 0, 1, 0, 0]);
  }

  void hideDecorations() {
    setMotifWmHints([2, 0, 0, 0, 0]);
  }

  private void setMotifWmHints(int[5] hints) {
    // The 5-element array is a replacement for the MotifWMHints structure. The first
    // element is the flags, which tells which of the following elements are set.
    // the decorations attribute is in the third element.

    setWindowProperty(handle, MOTIF_WM_HINTS, MOTIF_WM_HINTS, hints, 32, 5);
  }

  // system initialization

  private void checkXRenderExtension() {
    int eventBase, errorBase;

    auto enabled = XRenderQueryExtension(display, &eventBase, &errorBase);
    enforce(enabled, "No RENDER extension found.");
  }

  private glx.XVisualInfo* findVisual() {
    // TODO: fallback to a non-alpha one, if alpha not available.

    auto screen = DefaultScreen(display);

    int attribs[] = [GLX_RENDER_TYPE,   GLX_RGBA_BIT,
                     GLX_DRAWABLE_TYPE, GLX_WINDOW_BIT,
                     GLX_RED_SIZE,      1,
                     GLX_GREEN_SIZE,    1,
                     GLX_BLUE_SIZE,     1,
                     GLX_ALPHA_SIZE,    1,
                     GLX_DOUBLEBUFFER,  True,
                     GLX_DEPTH_SIZE,    1,
                     None];

    int numFbConfigs;
    auto fbConfigs = glXChooseFBConfig(display, screen, attribs.ptr, &numFbConfigs);
    enforce(fbConfigs, "No suitable framebuffer configuration found.");

    scope(exit) XFree(fbConfigs);

    auto visualInfo = findVisualWithAlpha(fbConfigs[0 .. numFbConfigs]);
    enforce(visualInfo, "No suitable visual found.");

    return visualInfo;
  }

  private glx.XVisualInfo* findVisualWithAlpha(GLXFBConfig[] configs) {
    typeof(return) result;

    foreach (config; configs) {
      auto visualInfo = glXGetVisualFromFBConfig(display, config);
      if (!visualInfo) continue;

      auto pictureFormat = XRenderFindVisualFormat(display, visualInfo.visual);
      if (!pictureFormat) continue;

      if (pictureFormat.direct.alphaMask > 0) {
        return visualInfo;
      }
    }

    return null;
  }

  private xlib.Window    handle;
  private xlib.Colormap  colormap;
  private glx.GLXContext context;
}

