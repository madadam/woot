module sen.x11.system;

public import derelict.opengl.glx;
public import X11.Xlib;

import derelict.util.xtypes;
import adapter;
import std.typetuple;

alias derelict.opengl.glx glx;
alias X11.Xlib            xlib;

// adapt some xlib functions so they acceps different params.
private alias TypeTuple!(glx.Visual*, xlib.Visual*) XlibTypeMap;
auto XCreateColormap = &adapt!(xlib.XCreateColormap, XlibTypeMap);
auto XCreateWindow   = &adapt!(xlib.XCreateWindow,   XlibTypeMap);

// adapt some glx functions so they acceps different params.
private alias TypeTuple!(xlib.Display*, glx.Display*,
                         xlib.Window,   glx.GLXDrawable) GLXTypeMap;
auto glXChooseVisual   = &adapt!(glx.glXChooseVisual,   GLXTypeMap);
auto glXCreateContext  = &adapt!(glx.glXCreateContext,  GLXTypeMap);
auto glXDestroyContext = &adapt!(glx.glXDestroyContext, GLXTypeMap);
auto glXMakeCurrent    = &adapt!(glx.glXMakeCurrent,    GLXTypeMap);
auto glXSwapBuffers    = &adapt!(glx.glXSwapBuffers,    GLXTypeMap);
