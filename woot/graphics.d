module woot.graphics;

public import derelict.opengl.gl;
public import derelict.opengl.glu;


// Load dynamic libs.
static this() {
  DerelictGL.load();
  DerelictGLU.load();
}
