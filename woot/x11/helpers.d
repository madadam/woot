module woot.x11.helpers;

import std.exception;
import std.string;
import std.traits;
import woot.log;
import woot.x11.backend;

// setWindowProperty
unittest {
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

  // Default value is returned if proterty is deleted.
  XDeleteProperty(display, window, atom);
  assert(getWindowProperty!Stuff(window, atom) is null);
}

void setWindowProperty(T)(X11.Xlib.Window handle, Atom name, T value) {
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
void setWindowProperty(T)(X11.Xlib.Window handle, Atom name, Atom type, T value, int format, int numElements) {
  XChangeProperty(display, handle, name, type, format, PropModeReplace, cast(ubyte*) &value, numElements);
}

// getWindowProperty
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

// internAtom
Atom internAtom(string name, bool onlyIfExists) {
  return xlib.XInternAtom(display, cast(byte*) toStringz(name), cast(xlib.Bool) onlyIfExists);
}
