module agent;

import board : Board;
import std.algorithm : min, max;

struct Action {
  int x, y;
  double score = -double.infinity;
}

// Min-max algorithm.
struct Agent {
  Action select(Board b) const {
    Action best;
    foreach (x; 0 .. b.length) {
      foreach (y; 0 .. b.length) {
        if (b.canUpdate(x, y, false)) {
          auto tmp = b;
          tmp.update(x, y, false);
          const score = search(tmp, true, 6);
          if (score > best.score) {
            best = Action(x, y, score);
          }
        }
      }
    }
    return best;
  }

  static int heuristic(bool isPlayerTurn, int x, int y) {
    // corners
    if ((x == 0 && y == 0) ||
        (x == 0 && y == Board.length - 1) ||
        (x == Board.length - 1 && y == 0) ||
        (x == Board.length - 1 && y == Board.length - 1)) return isPlayerTurn ? 16 : -16;
    return 0;
  }

  double search(Board b, bool isPlayerTurn, uint depth) const {
    if (depth == 0 || b.finished) return -b.score;

    if ((isPlayerTurn && b.pass(true)) || (!isPlayerTurn && b.pass(false)))
      return search(b, !isPlayerTurn, depth-1);

    auto alpha = -double.infinity;
    auto beta = double.infinity;
    foreach (x; 0 .. b.length) {
      foreach (y; 0 .. b.length) {
        if (b.canUpdate(x, y, isPlayerTurn)) {
          b.update(x, y, isPlayerTurn);
          const score = search(b, !isPlayerTurn, depth - 1) + heuristic(isPlayerTurn, x, y);
          if (isPlayerTurn && alpha < score) alpha = score;
          if (!isPlayerTurn && beta > score) beta = score;
        }
      }
    }
    return isPlayerTurn ? alpha : beta;
  }
}

// TODO(karita): Alpha-beta algorithm.
