import sen.application;
import sen.window;

void main() {
  auto window = new Window;

  window.title  = "hack!";
  window.width  = 640;
  window.height = 480;

  window.backgroundColor = [0.0, 0.0, 0.0, 0.0];
  window.hideDecorations();
  window.show();

  run();
}
