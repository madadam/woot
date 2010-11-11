module woot.graphics.setup;

public import derelict.devil.il;
public import derelict.devil.ilu;
public import derelict.devil.ilut;

public import derelict.opengl.gl;
public import derelict.opengl.glu;

static this() {
  // Load dynamic libs.
  DerelictGL.load();
  DerelictGLU.load();
  DerelictIL.load();
  DerelictILU.load();
  DerelictILUT.load();

  // Initialize the libs.
  ilInit();
  iluInit();
  ilutRenderer(ILUT_OPENGL);
}
