import w4 = wasm4;
import agent : Agent;
import board : Board;

enum margin = 8;

Board board = {
  margin,
  margin,
  w4.screenSize - margin * 2,
  w4.screenSize - margin * 2,
};

Agent agent;
bool isPlayerTurn = true;

extern(C) void start() {
  board.reset();
}

extern(C) void update() {
  if (isPlayerTurn) {
    isPlayerTurn = !board.mouse();
  } else {
    if (!board.pass(false)) {
      auto action = agent.select(board);
      board.update(action.x, action.y, false);
    }
    isPlayerTurn = true;
  }
  board.draw();

  *w4.drawColors = 3;
  w4.text("Score:", margin, 0);
  w4.text(itos(board.score).ptr, 64, 0);

  w4.text(isPlayerTurn ? "Your turn (black)" : "CPU turn (white)",
          margin, w4.screenSize - margin);
}

const(char)[] itos(int i) {
  if (i == 0) return "0";

  bool neg = i < 0;
  if (neg) i = -i;

  enum N = 100;
  static char[N] s = [ N - 1: 0 ];
  foreach_reverse (index; 0 .. N - 1) {
    s[index] = '0' + i % 10;
    i /= 10;
    if (i == 0) {
      if (!neg) return s[index .. $ - 1];
      s[index - 1] = '-';
      return s[index - 1 .. $ - 1];
    }
  }
  assert(false, "input is too large for char[N].");
}
