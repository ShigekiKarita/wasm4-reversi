import w4 = wasm4;

import std.algorithm : min;

struct Board {
  // GUI settings.
  int xmin;
  int ymin;
  uint width;
  uint height;

  enum length = 8;

  enum State {
    empty,
    black,
    white,
  }

  State[length][length] states;

  void reset() {
    states[3][3] = State.black;
    states[4][4] = State.black;
    states[3][4] = State.white;
    states[4][3] = State.white;
  }

  void draw() const {
    *w4.drawColors = 2;
    const xd = width / length;
    const yd = height / length;
    // Boundaries.
    w4.rect(xmin, ymin, width, height);
    foreach (i; 0 .. length + 1) {
      *w4.drawColors = 3;
      const xi = xmin + i * xd;
      w4.line(xi, ymin, xi, ymin + height);
      const yi = ymin + i * yd;
      w4.line(xmin, yi, xmin + width, yi);
    }

    // Ovals.
    foreach (i; 0 .. length) {
      foreach (j; 0 .. length) {
        auto s = states[i][j];
        if (s == State.empty) continue;
        *w4.drawColors = s == State.black ? 3 : 1;
        w4.oval(xmin + i * xd, ymin + j * yd, xd, yd);
      }
    }
  }

  bool mouse() {
    static ubyte prevState;
    const mouse = *w4.mouseButtons;
    const justPressed = mouse & (mouse ^ prevState);
    prevState = mouse;
    if (!(justPressed & w4.mouseLeft)) return false;

    auto x = (*w4.mouseX - xmin) / (width / length);
    auto y = (*w4.mouseY - ymin) / (height / length);
    if (states[x][y] != State.empty) return false;
    if (!canUpdate(x, y, true)) return false;

    states[x][y] = State.black;
    update(x, y, true);
    return true;
  }

  bool canUpdate(int x, int y, bool black) {
    if (x < 0 || length <= x || y < 0 || length <= y) return false;
    states[x][y] = State.black;
    auto tmp = states;
    update(x, y, black);
    auto ret = tmp != states;
    states = tmp;
    states[x][y] = State.empty;
    return ret;
  }

  void update(int x, int y, bool black) {
    auto color = black ? State.black : State.white;

    // horizontal
    foreach_reverse (yi; 0 .. y) {
      if (states[x][yi] == State.empty) break;
      if (states[x][yi] == color) {
        foreach (yj; yi .. y) states[x][yj] = color;
        break;
      }
    }
    foreach (yi; y + 1 .. length) {
      if (states[x][yi] == State.empty) break;
      if (states[x][yi] == color) {
        foreach (yj; y + 1 .. yi) states[x][yj] = color;
        break;
      }
    }

    // vertical
    foreach_reverse (xi; 0 .. x) {
      if (states[xi][y] == State.empty) break;
      if (states[xi][y] == color) {
        foreach (xj; xi .. x) states[xj][y] = color;
        break;
      }
    }
    foreach (xi; x + 1 .. length) {
      if (states[xi][y] == State.empty) break;
      if (states[xi][y] == color) {
        foreach (xj; x + 1 .. xi) states[xj][y] = color;
        break;
      }

    }

    // slash /
    foreach (i; 1 .. min(y, length - x - 1) + 1) {
      if (states[x - i][y + i] == State.empty) break;
      if (states[x - i][y + i] == color) {
        foreach (j; 1 .. i + 1) states[x - j][y + j] = color;
        break;
      }
    }
    foreach (i; 1 .. min(x, length - y - 1) + 1) {
      if (states[x + i][y - i] == State.empty) break;
      if (states[x + i][y - i] == color) {
        foreach (j; 1 .. i + 1) states[x + j][y - j] = color;
        break;
      }
    }

    // back slash
    foreach (i; 1 .. min(x, y) + 1) {
      if (states[x - i][y - i] == State.empty) break;
      if (states[x - i][y - i] == color) {
        foreach (j; 1 .. i + 1) states[x - j][y - j] = color;
        break;
      }
    }
    foreach (i; 1 .. min(length - y - 1, length - x - 1) + 1) {
      if (states[x + i][y + i] == State.empty) break;
      if (states[x + i][y + i] == color) {
        foreach (j; 1 .. i + 1) states[x + j][y + j] = color;
        break;
      }
    }
  }
}

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
