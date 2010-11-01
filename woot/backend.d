module woot.backend;

// Load a backend depending on the target platform.

version(linux) { version = x11; }

version(x11) {
  public import woot.x11.backend;

  // TODO: support macos, win32, ios, android, ...

} else {
  static assert(false, "Only X11 backend is supported for now.");
}
