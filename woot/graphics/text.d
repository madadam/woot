module woot.graphics.text;

import derelict.freetype.ft;

import meta.accessor;

import std.algorithm;
import std.array;
import std.exception;
import std.string;

import woot.init;
import woot.log;
import woot.math;
import woot.opengl;
import woot.string;

class Font {
  this(string path, int size) {
    FT_Error error;

    error = FT_New_Face(library, toStringz(path), 0, &_face);

    // TODO: throw appropriate exception depending on the error.
    enforce(error == 0, "Failed to load font " ~ path);

    error = FT_Set_Pixel_Sizes(_face, 0, size);
    enforce(error == 0, "Failed to set font size");
  }

  /// Find glyph by character.
  ref immutable(Glyph) findGlyph(dchar code) {
    return findGlyph(FT_Get_Char_Index(_face, code));
  }

  /// Find glyph by it's index in the font.
  ref immutable(Glyph) findGlyph(uint index) {
    if (index >= _glyphs.length) {
      bakeGlyphs(index);
    }

    return _glyphs[index];
  }

  @property
  uint numGlyphs() {
    return _face.num_glyphs;
  }

  /// Get kerning of two glyps.
  int[2] kerning(ref const Glyph left, ref const Glyph right) {
    FT_Vector delta;
    FT_Get_Kerning(_face, left.index, right.index, FT_Kerning_Mode.FT_KERNING_DEFAULT, &delta);

    return [delta.x >> 6, delta.y >> 6];
  }

  private void bakeGlyphs(uint upToIndex) {
    auto firstIndex = _glyphs.length;

    foreach (i; firstIndex .. upToIndex + 1) {
      _glyphs.length += 1;
      _glyphs[i].bake(_face, i);
    }
  }

  private FT_Face _face;
  private Glyph[] _glyphs;
}

void text(string input, Font font) {
  if (input.empty) { return; }

  double x = 0.0;
  double y = 0.0;

  auto chars     = chars(input);
  auto firstChar = chars.popAndReturnFront();

  Glyph previous = font.findGlyph(firstChar);

  renderGlyph(previous, x, y);

  x += previous.advanceX;
  y += previous.advanceY;

  foreach (c; chars) {
    auto current = font.findGlyph(c);
    auto kerning = font.kerning(previous, current);

    x += kerning[0];
    y += kerning[1];

    renderGlyph(current, x, y);

    x += current.advanceX;
    y += current.advanceY;

    previous = current;
  }
}

struct Glyph {
  mixin(getter!(int, "advanceX", "advanceY"));
  mixin(getter!(uint, "textureWidth", "textureHeight"));

  mixin(getter!(int, "left", "bottom"));

  @property int right() const { return left + textureWidth; }
  @property int top() const   { return bottom + textureHeight; }

  mixin(getter!(uint, "index"));

  private void bake(FT_Face face, uint index) {
    FT_Error error;

    error = FT_Load_Glyph(face, index, FT_LOAD_RENDER);
    enforce(error == 0, "Failed to load glyph");

    auto glyph = face.glyph;

    ubyte[] data;

    prepareBitmap(glyph.bitmap, _textureWidth, _textureHeight, data);

    glGenTextures(1, &_textureId);

    bindTexture();

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, textureWidth, textureHeight, 0, GL_ALPHA,
                 GL_UNSIGNED_BYTE, cast(void*) data.ptr);

    _advanceX = glyph.advance.x / 64;
    _advanceY = glyph.advance.y / 64;

    _left   = glyph.bitmap_left;
    _bottom = glyph.bitmap_top - glyph.bitmap.rows;

    _index = index;
  }

  private void bindTexture() const {
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _textureId);
  }

  private uint _textureId;
}

private void renderGlyph(ref const Glyph g, double x, double y) {
  g.bindTexture();

  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_BLEND);

  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

  auto left   = x + g.left;
  auto right  = x + g.right;
  auto bottom = y + g.bottom;
  auto top    = y + g.top;

  glBegin(GL_QUADS);
    glTexCoord2f(0.0, 1.0);
    glVertex2d(left, bottom);

    glTexCoord2f(1.0, 1.0);
    glVertex2d(right, bottom);

    glTexCoord2f(1.0, 0.0);
    glVertex2d(right, top);

    glTexCoord2f(0.0, 0.0);
    glVertex2d(left, top);
  glEnd();
}

// Helpers

private void prepareBitmap(ref const(FT_Bitmap) bitmap,
                           out uint width,
                           out uint height,
                           out ubyte[] data) {
  width  = nextPowerOfTwo(bitmap.width);
  height = nextPowerOfTwo(bitmap.rows);

  auto rowOffset = height - bitmap.rows;

  data = new ubyte[width * height];

  foreach(y; 0 .. bitmap.rows) {
    auto sourceOffset = y * bitmap.pitch;
    auto targetOffset = (y + rowOffset) * width;

    copy(bitmap.buffer[sourceOffset .. sourceOffset + bitmap.width],
         data[targetOffset .. targetOffset + bitmap.width]);

    fill(data[targetOffset + bitmap.width .. targetOffset + width], cast(ubyte) 0);
  }
}

unittest {
  // Common case

  FT_Bitmap b;
  b.rows   = 3;
  b.width  = 5;
  b.pitch  = 7;

  auto buffer = new ubyte[3 * 7];
  fill(buffer, cast(ubyte) 1);

  b.buffer = buffer.ptr;

  uint width, height;
  ubyte[] data;

  prepareBitmap(b, width, height, data);

  assert(8 == width);
  assert(4 == height);
  assert([0, 0, 0, 0, 0, 0, 0, 0,
          1, 1, 1, 1, 1, 0, 0, 0,
          1, 1, 1, 1, 1, 0, 0, 0,
          1, 1, 1, 1, 1, 0, 0, 0] == data);
}

unittest {
  // Degenerate cases - zero bitmap

  FT_Bitmap b;
  b.rows   = 0;
  b.width  = 0;
  b.pitch  = 0;
  b.buffer = null;

  uint width, height;
  ubyte[] data;

  prepareBitmap(b, width, height, data);

  assert(0 == width);
  assert(0 == height);
  assert(0 == data.length);
}

unittest {
  // Simple case - bitmap has already the right dimensions.

  FT_Bitmap b;
  b.rows   = 2;
  b.width  = 2;
  b.pitch  = 2;
  b.buffer = (cast(ubyte[]) [1, 1, 1, 1]).ptr;

  uint width, height;
  ubyte[] data;

  prepareBitmap(b, width, height, data);

  assert(2 == width);
  assert(2 == height);
  assert([1, 1,
          1, 1] == data);
}


// Library initialization

private FT_Library library;

static this() {
  DerelictFT.load();

  auto error = FT_Init_FreeType(&library);
  enforce(error == 0, "Error initializing FreeType library.");
}

static ~this() {
  if (library) { FT_Done_FreeType(library); }
}
