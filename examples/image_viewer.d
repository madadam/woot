import std.path;
import std.stdio;

import woot.application;
import woot.graphics.image;
import woot.window;

void main(string[] args) {
  if (args.length != 2) {
    writeln("Usage: " ~ basename(args[0]) ~ " file");
    return;
  }

  try {
    auto window = new Window;
    auto img    = new Image(args[1]);

    window.paintRequested.connect({ image(img); });
    window.keyPressed.connect(&window.close);

    window.title  = args[1];
    window.width  = img.width;
    window.height = img.height;

    window.show();
    run();
  } catch (FileNotFound e) {
    writeln(e.msg);
  } catch (UnknownImageType e) {
    writeln(e.msg);
  }
}
