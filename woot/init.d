module woot.init;

import woot.opengl;
static import backend = woot.backend;

static this() {
  DerelictGL.load();
  DerelictGLU.load();

  backend.init();
}
