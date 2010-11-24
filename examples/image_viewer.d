import std.path;
import std.stdio;

import woot.application;
import woot.color;
import woot.graphics.image;
import woot.graphics.text;
import woot.opengl;
import woot.string;
import woot.window;

void main(string[] args) {
  // if (args.length != 2) {
  //   writeln("Usage: " ~ basename(args[0]) ~ " file");
  //   return;
  // }

  try {
    auto window = new Window;
    // auto img    = new Image(args[1]);
    auto font   = new Font("/usr/share/fonts/TTF/DejaVuSans.ttf", 30);

    window.paintRequested.connect({
      // image(img);

      glMatrixMode(GL_MODELVIEW);
      glPushMatrix();

      glTranslatef(50.0, 50.0, 0.0);
      glColor3f(0.0, 0.0, 0.0);

      text("Hello world", font);

      glPopMatrix();
    });

    window.keyPressed.connect(&window.close);

    // window.title  = args[1];
    // window.width  = img.width;
    // window.height = img.height;

    window.show();
    run();
  } catch (FileNotFound e) {
    writeln(e.msg);
  } catch (UnknownImageType e) {
    writeln(e.msg);
  }
}
