import w4 = wasm4;
import board : Board;

enum margin = 8;

Board board = {
  margin,
  margin,
  w4.screenSize - margin * 2,
  w4.screenSize - margin * 2,
};

extern(C) void start() {
  board.reset();
}

extern(C) void update() {
  board.mouse();
  board.draw();

  *w4.drawColors = 3;
  w4.text("Score:", margin, 0);
  w4.text("Your turn", margin, w4.screenSize - margin);
}
