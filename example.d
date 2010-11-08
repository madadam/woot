import woot.application;
import woot.color;
import woot.graphics;
import woot.layout.horizontal;
import woot.layout.vertical;
import woot.widget;
import woot.window;

void main() {
  auto window = new Window;

  auto boxR = new Widget;
  boxR.backgroundColor = red;
  boxR.paintRequested.connect({
    glBegin(GL_TRIANGLES);
      glColor3f(1.0, 1.0, 1.0);

      glVertex2f(10.0,              10.0);
      glVertex2f(boxR.width - 10.0, 10.0);
      glVertex2f(boxR.width / 2.0,  boxR.height - 10.0);
    glEnd();
  });

  auto boxG = new Widget;
  boxG.backgroundColor = green;

  auto boxB = new Widget;
  boxB.backgroundColor = blue;

  window.add(boxR, boxG, boxB);

  auto layout = new HorizontalLayout;
  // auto layout = new VerticalLayout;
  layout.spacing = 50.0;
  layout.attach(window);

  window.keyPressed.connect(&window.close);

  window.title  = "w00t!";
  window.width  = 640;
  window.height = 480;

  window.backgroundColor = rgba(0.0, 0.0, 0.0, 0.8);
  // window.hideDecorations();
  window.show();

  run();
}
