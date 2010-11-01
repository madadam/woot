module sen.event;

import std.algorithm;

/**
 * Event.
 *
 * TODO: Documentation here.
 */
struct Event(T...) {
  alias void delegate(T) Listener;

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

  void opCall(T params) {
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

  e();
  assert([] == calls);
}

// no parameters
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });

  e();
  assert(["one"] == calls);

  e();
  assert(["one", "one"] == calls);
}

// with parameters
unittest {
  clearCalls();

  Event!string e1;
  e1.connect((string s) { call(s); });

  e1("one");
  assert(["one"] == calls);

  e1("two");
  assert(["one", "two"] == calls);

  clearCalls();

  Event!(string, string) e2;
  e2.connect((string a, string b) { call(a ~ "+" ~ b); });

  e2("one", "two");
  assert(["one+two"] == calls);

  e2("three", "four");
  assert(["one+two", "three+four"] == calls);
}

// multiple listeners
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });
  e.connect({ call("two"); });

  e();
  assert(["one", "two"] == calls);

  e();
  assert(["one", "two", "one", "two"] == calls);
}

// disconnect
unittest {
  clearCalls();

  Event!() e;
  auto listener = { call("one"); };

  e.connect(listener);
  e.disconnect(listener);
  e();
  assert([] == calls);
}

// disconnect all
unittest {
  clearCalls();

  Event!() e;
  e.connect({ call("one"); });
  e.connect({ call("two"); });

  e.disconnectAll();
  e();
  assert([] == calls);
}
