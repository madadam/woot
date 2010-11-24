module woot.string;

import std.c.string;
import std.range : isInputRange;
import std.utf;

/// Collection of string related utilities.

/**
 * Returns a range that efficiently iterates over a string yielding UTF32 characters.
 */
Chars chars(string input) { return Chars(input); }

unittest {
  dchar[] output;

  foreach(d; chars("")) { output ~= d; }
  assert([] == output);

  output = [];
  foreach(d; chars("a")) { output ~= d; }
  assert("a"d == output);

  output = [];
  foreach(d; chars("abcd")) { output ~= d; }
  assert("abcd"d == output);

  output = [];
  foreach(d; chars("mañana")) { output ~= d; }
  assert("mañana"d == output);

  output = [];
  foreach(d; chars("你好")) { output ~= d; }
  assert("你好"d == output);
}

private struct Chars {
  this(string input) {
    this.input = input;
  }

  void popFront() {
    index += stride(input, index);
  }

  /// Return first char, then pop it.
  dchar popAndReturnFront() {
    auto result = front;
    popFront();
    return result;
  }

  @property
  bool empty() {
    return index >= input.length;
  }

  @property
  dchar front() {
    auto temp = index;
    return decode(input, temp);
  }

  private string input;
  private size_t index;
}

unittest {
  assert(isInputRange!Chars);
}

/**
 * Convert a C-style null-terminated string into a D-style string.
 */
string fromStringz(const(char)* input) {
  return input ? cast(string) input[0 .. strlen(input)] : "";
}

unittest {
  char[] input1 = ['a', 'b', 'c', 'd', '\0'];
  assert("abcd" == fromStringz(input1.ptr));

  assert("" == fromStringz(null));

  char[] input2 = ['\0'];
  assert("" == fromStringz(input2.ptr));
}
