module woot.graphics.image;

import meta.accessor;
import std.exception;
import std.string;
public import woot.graphics.setup;

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
    enforce(ilGetError() == IL_NO_ERROR, "Failed to load image " ~ path);

    _width  = ilGetInteger(IL_IMAGE_WIDTH);
    _height = ilGetInteger(IL_IMAGE_HEIGHT);

    id = ilutGLBindTexImage();
    ilDeleteImages(1, &image);
  }

  private uint id;
}

void paint(Image image) {
  glEnable(GL_TEXTURE_2D);
  glBindTexture(GL_TEXTURE_2D, image.id);

  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 0.0); glVertex2f(0.0,         0.0);
		glTexCoord2f(1.0, 0.0); glVertex2f(image.width, 0.0);
		glTexCoord2f(1.0, 1.0); glVertex2f(image.width, image.height);
		glTexCoord2f(0.0, 1.0); glVertex2f(0.0,         image.height);
  glEnd();

  glDisable(GL_TEXTURE_2D);
}
