import woot.application;
import woot.color;
import woot.graphics.image;
import woot.layout.horizontal;
import woot.widget;
import woot.window;

void main() {
  auto window = new Window;

  auto image = new Image("resources/cthulhu.jpg");

  window.paintRequested.connect({ paint(image); });
  window.keyPressed.connect(&window.close);

  window.title  = "w00t!";
  window.width  = 640;
  window.height = 480;

  window.backgroundColor = rgba(0.0, 0.0, 0.0, 0.8);
  // window.hideDecorations();
  window.show();

  run();
}
