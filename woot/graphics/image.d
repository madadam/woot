module woot.graphics.image;

import derelict.devil.il;
import derelict.devil.ilu;
import derelict.devil.ilut;

import meta.accessor;
import std.exception;
import std.file;
import std.string;

import woot.init;
import woot.opengl;

/// Exception thrown when file is not found.
class FileNotFound : FileException {
  this(string message) { super(message); }
}

/**
 * Exception thrown on attempt to open unknown image type.
 *
 * Supported image types can be found here: http://openil.sourceforge.net/features.php
 */
class UnknownImageType : Exception {
  this(string message) { super(message); }
}

class Image {
  this(string path) {
    load(path);
  }

  mixin(getter!(uint, "width", "height"));

  private void load(string path) {
    uint image;

    ilGenImages(1, &image);
    ilBindImage(image);

    ilLoadImage(toStringz(path));
    auto error = ilGetError();

    switch (error) {
      case IL_NO_ERROR:
        break; // OK
      case IL_COULD_NOT_OPEN_FILE:
        throw new FileNotFound("File " ~ path ~ " was not found");
      case IL_INVALID_EXTENSION:
        throw new UnknownImageType("Unknown image type in file " ~ path);
      default:
        throw new Exception(format(iluErrorString(error)));
    }

    _width  = ilGetInteger(IL_IMAGE_WIDTH);
    _height = ilGetInteger(IL_IMAGE_HEIGHT);

    id = ilutGLBindTexImage();
    ilDeleteImages(1, &image);
  }

  private uint id;
}

/// Render image.
void image(Image source) {
  image(source, source.width, source.height);
}

/// Render image with given with and height.
void image(Image source, double width, double height) {
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, source.id);

  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex2d(0.0,   0.0);
		glTexCoord2f(1.0, 0.0); glVertex2d(width, 0.0);
		glTexCoord2f(1.0, 1.0); glVertex2d(width, height);
		glTexCoord2f(0.0, 1.0); glVertex2d(0.0,   height);
  glEnd();

  glDisable(GL_TEXTURE_2D);
}

static this() {
  DerelictIL.load();
  DerelictILU.load();
  DerelictILUT.load();

  ilInit();
  iluInit();
  ilutRenderer(ILUT_OPENGL);
}
