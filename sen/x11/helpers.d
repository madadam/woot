module sen.x11.helpers;

import sen.x11.backend;
import std.exception;
import std.string;

// setWindowProperty
unittest {
  auto window = XCreateSimpleWindow(display, XDefaultRootWindow(display),
                                    0, 0, 100, 100, 0, 0, 0);
  scope(exit) { XDestroyWindow(display, window); }

  class Stuff {};

  auto atom = XInternAtom(display, "test", false);
  auto value = new Stuff;

  // Set property can be got back.
  setWindowProperty(window, atom, &value);
  assert(value == getWindowProperty!Stuff(window, atom));

  // Default value is returned of proterty is deleted.
  XDeleteProperty(display, window, atom);
  assert(getWindowProperty!Stuff(window, atom) is null);
}

void setWindowProperty(T)(X11.Xlib.Window handle, Atom name, T value) {
  XChangeProperty(display,
                  handle,
                  name,
                  _ANY,
                  8,
                  PropModeReplace,
                  cast(ubyte*) value,
                  T.sizeof);
}

// Read a value from a raw byte array.
private T read(T)(const ubyte* data) {
  union Convertor {
    ubyte[T.sizeof] bytes;
    T               value;
  };

  Convertor convertor;

  convertor.bytes = data[0 .. T.sizeof];
  return convertor.value;
}

// getWindowProperty
T getWindowProperty(T)(X11.Xlib.Window handle, Atom name) {
  ubyte* bytes;
  int format;
  uint numItems;

  Atom actualType;
  uint ignoredBytesAfter;

  XGetWindowProperty(display,
                     handle,
                     name,
                     0,
                     cast(int) T.sizeof / 4,
                     cast(Bool) false,
                     AnyPropertyType,
                     &actualType,
                     &format,
                     &numItems,
                     &ignoredBytesAfter,
                     &bytes);

  if (actualType == None && format == 0) {
    return T.init;
  } else {
    enforce(T.sizeof == (numItems * format) / 8, "Invalid property type");
    scope(exit) { XFree(bytes); }

    return read!T(bytes);
  }
}

// internAtom
Atom internAtom(string name, bool onlyIfExists) {
  return xlib.XInternAtom(display, cast(byte*) toStringz(name), cast(xlib.Bool) onlyIfExists);
}
