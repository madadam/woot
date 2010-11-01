module sen.log;

import std.stdio;

// Log stuff.
// TODO: make this a no-op in release mode.
void log(T...)(T values) {
  writeln(values);
}
