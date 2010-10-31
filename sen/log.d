module sen.log;

import std.stdio;

// TODO: Make this a no-op in release mode.
void log(string message) {
  writeln(message);
}
