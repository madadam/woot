module sen.x11.backend;

public import sen.x11.system;

import sen.window;
import sen.x11.helpers;
import sen.x11.window;
import std.exception;

alias sen.x11.window.Window Window;

void processEvent() {
  XEvent event;
  XNextEvent(display, &event);

  auto target = getWindowProperty!(sen.window.Window)(event.xany.window, _THIS);

  switch (event.type) {
    case ClientMessage:
      if (target && event.xclient.l[0] == _WM_DELETE_WINDOW) {
        target.requestClose();
      }
      break;
    case Expose:
      if (event.xexpose.count == 0) {
        target.requestPaint();
      }
      break;
    case KeyPress:
      // target.keyPressed(findKey(event.xkey.keycode));
      break;
    default:
  }
}

// X Connection
package xlib.Display* display;

static this() {
  display = XOpenDisplay(null);
  enforce(display, "Connection with the X Server can't be established.");
}

// Atoms
package Atom _ANY;
package Atom _THIS;
package Atom _WM_DELETE_WINDOW;

static this() {
  _ANY              = internAtom("sen:any",  false);
  _THIS             = internAtom("sen:this", false);
  _WM_DELETE_WINDOW = internAtom("WM_DELETE_WINDOW", true);
}

// Make derelict play nice with Xlib
