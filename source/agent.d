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
          const score = search(tmp, true, 5);
          if (score > best.score) {
            best = Action(x, y, score);
          }
        }
      }
    }
    return best;
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
          const score = search(b, !isPlayerTurn, depth - 1);
          if (isPlayerTurn && alpha < score) alpha = score;
          if (!isPlayerTurn && beta > score) beta = score;
        }
      }
    }
    return isPlayerTurn ? alpha : beta;
  }
}

// TODO(karita): Alpha-beta algorithm.
