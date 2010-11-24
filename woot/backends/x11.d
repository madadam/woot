module woot.backends.x11;

import derelict.opengl.glx;
static import derelict.util.xtypes;

import meta.adapter;

import std.exception;
import std.math;
import std.string;
import std.traits;
import std.typetuple;

import X11.Xlib;
import X11.Xatom;
import X11.extensions.Xrender;

import woot.log;
import woot.opengl;
import woot.window;

struct Window {
  void initialize(woot.window.Window window) {
    auto rootWindow = RootWindow(display, visualInfo.screen);

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

    // Function from higher OpenGL versions can only be loaded after OpenGL has been
    // initialized and made current.
    DerelictGL.loadExtendedVersions();
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
  double width() {
    return geometry[2];
  }

  @property
  double width(double value) {
    XWindowChanges changes;
    changes.width = cast(int) round(value);

    XConfigureWindow(display, handle, CWWidth, &changes);
    return value;
  }

  @property
  double height() {
    return geometry[3];
  }

  @property
  double height(double value) {
    XWindowChanges changes;
    changes.height = cast(int) round(value);

    XConfigureWindow(display, handle, CWHeight, &changes);
    return value;
  }

  @property
  double[2] size() {
    auto geometry = this.geometry;
    return [geometry[2], geometry[3]];
  }

  @property
  double[4] geometry() {
    xlib.Window ignoredRoot;
    uint        ignoredStuff;
    int[4]      result;

    XGetGeometry(display, handle, &ignoredRoot,
                 &result[0], &result[1], cast(uint*) &result[2], cast(uint*) &result[3],
                 &ignoredStuff, &ignoredStuff);

    return [cast(double) result[0],
            cast(double) result[1],
            cast(double) result[2],
            cast(double) result[3]];
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

  private xlib.Window    handle;
  private xlib.Colormap  colormap;
}

void init() {
  if (initialized) {
    return;
  }

  display = XOpenDisplay(null);
  enforce(display, "Connection with the X Server can't be established.");

  // Init atoms.
  ANY              = internAtom("_ANY",             false);
  THIS             = internAtom("_THIS",            false);
  WM_DELETE_WINDOW = internAtom("WM_DELETE_WINDOW", true);
  NET_WM_NAME      = internAtom("_NET_WM_NAME",     true);
  UTF8_STRING      = internAtom("UTF8_STRING",      true);
  MOTIF_WM_HINTS   = internAtom("_MOTIF_WM_HINTS",  true);

  // Create GL context.
  visualInfo = findVisual();
  context = glXCreateContext(display, visualInfo, null, true);
  enforce(context, "Failed to create GL context.");

  initialized = true;
}

void processEvent() {
  XEvent event;
  XNextEvent(display, &event);

  auto target = getWindowProperty!(woot.window.Window)(event.xany.window, THIS);

  switch (event.type) {
    case ClientMessage:
      if (target && event.xclient.l[0] == WM_DELETE_WINDOW) {
        target.requestClose();
      }
      break;
    case ConfigureNotify:
      target.resized.trigger();
      break;
    case Expose:
      if (event.xexpose.count == 0) {
        target.paint();
      }
      break;
    case KeyPress:
      // target.keyPressed(findKey(event.xkey.keycode));
      target.keyPressed.trigger();
      break;
    default:
  }
}

private {
  alias derelict.opengl.glx    glx;
  alias X11.Xlib               xlib;
  alias X11.extensions.Xrender xrender;

  bool             initialized;
  xlib.Display*    display;
  glx.GLXContext   context;
  glx.XVisualInfo* visualInfo;

  Atom ANY;
  Atom THIS;
  Atom WM_DELETE_WINDOW;
  Atom NET_WM_NAME;
  Atom UTF8_STRING;
  Atom MOTIF_WM_HINTS;



  // adapt some xlib functions so they acceps different params.
  private alias TypeTuple!(glx.Visual*, xlib.Visual*) XlibTypeMap;
  auto XCreateColormap         = &adapt!(xlib.XCreateColormap, XlibTypeMap);
  auto XCreateWindow           = &adapt!(xlib.XCreateWindow,   XlibTypeMap);

  // TODO: This one done manually, because adapt chokes on the const business.
  XRenderPictFormat* XRenderFindVisualFormat(xlib.Display* display, const glx.Visual* visual) {
    return xrender.XRenderFindVisualFormat(display, cast(const(xlib.Visual*)) visual);
  }

  // adapt some glx functions so they acceps different params.
  private alias TypeTuple!(xlib.Display*, glx.Display*,
                           xlib.Window,   glx.GLXDrawable) GLXTypeMap;
  auto glXChooseVisual          = &adapt!(glx.glXChooseVisual,          GLXTypeMap);
  auto glXChooseFBConfig        = &adapt!(glx.glXChooseFBConfig,        GLXTypeMap);
  auto glXGetVisualFromFBConfig = &adapt!(glx.glXGetVisualFromFBConfig, GLXTypeMap);
  auto glXCreateContext         = &adapt!(glx.glXCreateContext,         GLXTypeMap);
  auto glXDestroyContext        = &adapt!(glx.glXDestroyContext,        GLXTypeMap);
  auto glXMakeCurrent           = &adapt!(glx.glXMakeCurrent,           GLXTypeMap);
  auto glXSwapBuffers           = &adapt!(glx.glXSwapBuffers,           GLXTypeMap);



  glx.XVisualInfo* findVisual() {
    // TODO: fallback to a non-alpha one, if alpha not available.
    checkXRenderExtension();

    auto screen = DefaultScreen(display);

    int attribs[] = [GLX_RENDER_TYPE,    GLX_RGBA_BIT,
                     GLX_DRAWABLE_TYPE,  GLX_WINDOW_BIT,
                     GLX_RED_SIZE,       1,
                     GLX_GREEN_SIZE,     1,
                     GLX_BLUE_SIZE,      1,
                     GLX_ALPHA_SIZE,     1,
                     GLX_DOUBLEBUFFER,   True,
                     GLX_DEPTH_SIZE,     1,
                     GLX_SAMPLE_BUFFERS, True,
                     GLX_SAMPLES,        4,
                     None];

    int numFbConfigs;
    auto fbConfigs = glXChooseFBConfig(display, screen, attribs.ptr, &numFbConfigs);
    enforce(fbConfigs, "No suitable framebuffer configuration found.");

    scope(exit) XFree(fbConfigs);

    auto visualInfo = findVisualWithAlpha(fbConfigs[0 .. numFbConfigs]);
    enforce(visualInfo, "No suitable visual found.");

    return visualInfo;
  }

  void checkXRenderExtension() {
    int eventBase, errorBase;

    auto enabled = XRenderQueryExtension(display, &eventBase, &errorBase);
    enforce(enabled, "No RENDER extension found.");
  }

  glx.XVisualInfo* findVisualWithAlpha(GLXFBConfig[] configs) {
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

  void setWindowProperty(T)(xlib.Window handle, Atom name, T value) {
    // TODO: Generalize the string case to any array.

    static if (is(T == string)) {
      auto type = UTF8_STRING;
      auto data  = cast(ubyte*) value.ptr;
      auto size = value.length * char.sizeof;
    } else {
      auto type = ANY;
      auto size = T.sizeof;

      static if (isPointer!T) {
        auto data = cast(ubyte*) value;
      } else {
        auto data = cast(ubyte*) &value;
      }
    }

    XChangeProperty(display, handle, name, type, 8, PropModeReplace, data, size);
  }

  // Low-level style.
  void setWindowProperty(T)(xlib.Window handle, Atom name, Atom type, T value, int format, int numElements) {
    XChangeProperty(display, handle, name, type, format, PropModeReplace, cast(ubyte*) &value, numElements);
  }

  T getWindowProperty(T)(X11.Xlib.Window handle, Atom name) {
    ubyte* bytes;
    int format;
    uint numItems;

    Atom actualType;
    uint ignoredBytesAfter;

    XGetWindowProperty(display, handle, name, 0, int.max, cast(Bool) false, AnyPropertyType,
                       &actualType, &format, &numItems, &ignoredBytesAfter, &bytes);

    if (actualType == None && format == 0) {
      return T.init;
    } else {
      auto actualSize = (numItems * format) / 8;

      // TODO: Generalize the string case to any array.

      static if (is(T == string)) {
        enforce(UTF8_STRING == actualType, "Invlaid property type");
      } else {
        enforce(T.sizeof == actualSize, "Invalid property type");
      }

      scope(exit) { XFree(bytes); }

      static if (is(T == string)) {
        return cast(string) bytes[0 .. actualSize].dup;
      } else {
        return *(cast(T*) bytes);
      }
    }
  }

  unittest {
    init();

    auto window = XCreateSimpleWindow(display, XDefaultRootWindow(display),
                                      0, 0, 100, 100, 0, 0, 0);
    scope(exit) { XDestroyWindow(display, window); }

    class  Stuff {}
    struct Point { int x; int y; }

    auto atom = internAtom("test", false);

    // Set/get pointers
    auto value = new Stuff;
    setWindowProperty(window, atom, &value);
    assert(value == getWindowProperty!Stuff(window, atom));

    // Set/get strings
    setWindowProperty(window, atom, "hello world");
    assert("hello world" == getWindowProperty!string(window, atom));

    // Set/get plain values
    auto point = Point(123, 456);
    setWindowProperty(window, atom, point);
    assert(Point(123, 456) == getWindowProperty!Point(window, atom));

    // Default value is returned if property is deleted.
    XDeleteProperty(display, window, atom);
    assert(getWindowProperty!Stuff(window, atom) is null);
  }

  Atom internAtom(string name, bool onlyIfExists) {
    return xlib.XInternAtom(display, cast(byte*) toStringz(name), cast(xlib.Bool) onlyIfExists);
  }
}
