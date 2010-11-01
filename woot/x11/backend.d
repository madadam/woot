module woot.x11.backend;

public import woot.x11.system;

import std.exception;
import woot.log;
import woot.window;
import woot.x11.helpers;
import woot.x11.window;

alias woot.x11.window.Window Window;

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
      target.resized();
      break;
    case Expose:
      if (event.xexpose.count == 0) {
        target.paint();
      }
      break;
    case KeyPress:
      // target.keyPressed(findKey(event.xkey.keycode));
      target.keyPressed();
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
package Atom ANY;
package Atom THIS;
package Atom WM_DELETE_WINDOW;
package Atom NET_WM_NAME;
package Atom UTF8_STRING;
package Atom MOTIF_WM_HINTS;

static this() {
  ANY              = internAtom("_ANY",             false);
  THIS             = internAtom("_THIS",            false);
  WM_DELETE_WINDOW = internAtom("WM_DELETE_WINDOW", true);
  NET_WM_NAME      = internAtom("_NET_WM_NAME",     true);
  UTF8_STRING      = internAtom("UTF8_STRING",      true);
  MOTIF_WM_HINTS   = internAtom("_MOTIF_WM_HINTS",  true);
}