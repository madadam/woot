module woot.event;

import std.algorithm;

/**
 * Event.
 *
 * TODO: Documentation here.
 */
struct Event(T...) {
  alias void delegate(T) Listener;

  @disable void opAssign(Event!T);

  void connect(Listener listener) {
    listeners ~= listener;
  }

  void disconnect(Listener listener) {
    auto index = indexOf(listeners, listener);

    if (index >= 0) {
      listeners = remove(listeners, index);
    }
  }

  void disconnectAll() {
    listeners = [];
  }

  void trigger(T params) {
    foreach(listener; listeners) {
      listener(params);
    }
  }

  private Listener[] listeners;
}

version(unittest) {
  string[] calls;

  void clearCalls() {
    calls = [];
  }

  void call(string label) {
    calls ~= label;
  }
}

// no listeners
unittest {
  clearCalls();
  Event!() e;

  e.trigger();
  assert([] == calls);
}

// no parameters
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });

  e.trigger();
  assert(["one"] == calls);

  e.trigger();
  assert(["one", "one"] == calls);
}

// with parameters
unittest {
  clearCalls();

  Event!string e1;
  e1.connect((string s) { call(s); });

  e1.trigger("one");
  assert(["one"] == calls);

  e1.trigger("two");
  assert(["one", "two"] == calls);

  clearCalls();

  Event!(string, string) e2;
  e2.connect((string a, string b) { call(a ~ "+" ~ b); });

  e2.trigger("one", "two");
  assert(["one+two"] == calls);

  e2.trigger("three", "four");
  assert(["one+two", "three+four"] == calls);
}

// multiple listeners
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });
  e.connect({ call("two"); });

  e.trigger();
  assert(["one", "two"] == calls);

  e.trigger();
  assert(["one", "two", "one", "two"] == calls);
}

// disconnect
unittest {
  clearCalls();

  Event!() e;
  auto listener = { call("one"); };

  e.connect(listener);
  e.disconnect(listener);
  e.trigger();
  assert([] == calls);
}

// disconnect all
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });
  e.connect({ call("two"); });

  e.disconnectAll();
  e.trigger();
  assert([] == calls);
}

/**
 * Mix-in an event into a class/struct:
 *
 * Examples:
 * ----------------
 * class Button {
 *   mixin(event!("clicked"));
 * }
 * ----------------
 **/
pure string event(string name, T...)() {
  auto type = "Event!" ~ T.stringof;

  return "@property ref " ~ type ~ " " ~ name ~ "() { return _" ~ name ~ "; }" ~
         "private " ~ type ~ " _" ~ name ~ ";";
}

unittest {
  clearCalls();

  class Widget {
    mixin(event!"clicked");
  }

  auto widget = new Widget;
  widget.clicked.connect({ call("click"); });

  widget.clicked.trigger();
  assert(["click"] == calls);
}
