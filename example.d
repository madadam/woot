import woot.application;
import woot.window;

void main() {
  auto window = new Window;

  window.paintRequested.connect({
    glBegin(GL_TRIANGLES);
      glColor4f(1.0, 0.0, 0.0, 0.1);
      glVertex2f(0.1, 0.1);

      glColor4f(0.0, 1.0, 0.0, 0.1);
      glVertex2f(0.9, 0.1);

      glColor4f(0.0, 0.0, 1.0, 0.1);
      glVertex2f(0.5, 0.9);
    glEnd();
  });

  window.keyPressed.connect(&window.close);

  window.title  = "hack!";
  window.width  = 640;
  window.height = 480;

  window.backgroundColor = [0.0, 0.0, 0.0, 0.0];
  window.hideDecorations();
  window.show();

  run();
}
