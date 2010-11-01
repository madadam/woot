module woot.x11.system;

public import derelict.opengl.glx;
public import X11.Xlib;
public import X11.Xatom;
public import X11.extensions.Xrender;

import derelict.util.xtypes;
import meta.adapter;
import std.typetuple;

alias derelict.opengl.glx    glx;
alias X11.Xlib               xlib;
alias X11.extensions.Xrender xrender;

// adapt some xlib functions so they acceps different params.
private alias TypeTuple!(glx.Visual*, xlib.Visual*) XlibTypeMap;
auto XCreateColormap         = &adapt!(xlib.XCreateColormap, XlibTypeMap);
auto XCreateWindow           = &adapt!(xlib.XCreateWindow,   XlibTypeMap);

// TODO: This one done manually, because adapt chokes on this const business.
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
