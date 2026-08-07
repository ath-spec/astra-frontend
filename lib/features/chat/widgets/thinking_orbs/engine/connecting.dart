import 'dart:math';
import 'dart:ui';
import 'core.dart';

// ---------------------------------------------------------------------------
// CONNECTING — "a constellation wires itself"
//
// The animation cycle:
//   1. N nodes (Fibonacci-distributed on the sphere surface) fade in one by one
//   2. K nearest-neighbour edges draw themselves sequentially as glowing arcs
//   3. A brief "hold" pause while the full constellation glows
//   4. Everything fades out and the cycle restarts
// ---------------------------------------------------------------------------

const int _kNodes = 11;
const int _kEdgesPerNode = 2; // number of nearest neighbours each node wires to
const double _kCycleDur = 6.4; // seconds per full cycle
const double _kNodeFrac = 0.22; // fraction of cycle spent fading nodes in
const double _kEdgeFrac = 0.48; // fraction of cycle spent drawing edges
const double _kHoldFrac = 0.15; // fraction of cycle holding completed constellation

// ---------------------------------------------------------------------------
// Edge definition: indices into the node list
// ---------------------------------------------------------------------------
class _Edge {
  final int a;
  final int b;
  _Edge(this.a, this.b);
}

// ---------------------------------------------------------------------------
// Pre-compute stable node positions and edge pairs (deterministic from seed).
// We recompute each time drawConnecting is called but these values are
// identical every frame since they only depend on _kNodes / _kEdgesPerNode.
// ---------------------------------------------------------------------------
List<List<double>> _buildNodes() {
  final nodes = <List<double>>[];
  for (int i = 0; i < _kNodes; i++) {
    final d = fibDir(i, _kNodes);
    nodes.add(d); // [x, y, z] on unit sphere
  }
  return nodes;
}

List<_Edge> _buildEdges(List<List<double>> nodes) {
  final edges = <_Edge>[];
  final seen = <String>{};

  for (int i = 0; i < nodes.length; i++) {
    // Compute distances to all others
    final dists = <int, double>{};
    for (int j = 0; j < nodes.length; j++) {
      if (j == i) continue;
      final dx = nodes[i][0] - nodes[j][0];
      final dy = nodes[i][1] - nodes[j][1];
      final dz = nodes[i][2] - nodes[j][2];
      dists[j] = dx * dx + dy * dy + dz * dz;
    }

    // Pick the _kEdgesPerNode closest
    final sorted = dists.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (int k = 0; k < min(_kEdgesPerNode, sorted.length); k++) {
      final j = sorted[k].key;
      final key = i < j ? '$i-$j' : '$j-$i';
      if (!seen.contains(key)) {
        seen.add(key);
        edges.add(_Edge(i, j));
      }
    }
  }
  return edges;
}

// ---------------------------------------------------------------------------
// Paint helper: dotted line between two projected points.
// 'progress' ∈ [0,1] — how much of the edge has been drawn.
// ---------------------------------------------------------------------------
void _paintEdge(
  Canvas ctx,
  Offset from,
  Offset to,
  double progress,
  double alpha,
  bool dark,
  double dotR,
) {
  if (progress <= 0 || alpha <= 0) return;
  const int kSteps = 18;
  final g = dark ? 200 : 55; // dot grey value
  final paint = Paint()
    ..color = Color.fromARGB((alpha * 255).round().clamp(0, 255), g, g, g)
    ..style = PaintingStyle.fill;

  final endStep = (progress * kSteps).round().clamp(0, kSteps);
  for (int s = 0; s <= endStep; s++) {
    final f = s / kSteps;
    final px = from.dx + (to.dx - from.dx) * f;
    final py = from.dy + (to.dy - from.dy) * f;
    ctx.drawCircle(Offset(px, py), dotR, paint);
  }
}

// ---------------------------------------------------------------------------
// Main draw function — follows the same signature as the other engine modes.
// ---------------------------------------------------------------------------
void drawConnecting(Canvas ctx, double size, double t, bool dark, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.82;
  final rs = radiusScale(size, o.get('rsPow', 0.6));

  // Slowly rotate the whole constellation
  final yaw = t * 0.18;
  final tilt = 0.32 + 0.08 * sin(t * 0.41);
  final proj = makeProj(yaw, tilt, cx, cy, R);

  final nodes = _buildNodes();
  final edges = _buildEdges(nodes);

  // --- Cycle timing --------------------------------------------------------
  final tc = t % _kCycleDur;
  final nodeEndT = _kCycleDur * _kNodeFrac;
  final edgeEndT = nodeEndT + _kCycleDur * _kEdgeFrac;
  final holdEndT = edgeEndT + _kCycleDur * _kHoldFrac;
  // After holdEndT → fade out everything, then loop

  // Node reveal progress (per-node stagger)
  double nodeProgress(int i) {
    final nodeSlot = nodeEndT / _kNodes;
    final start = i * nodeSlot;
    final end = start + nodeSlot;
    if (tc < start) return 0;
    if (tc > end) return 1;
    return ((tc - start) / (end - start)).clamp(0.0, 1.0);
  }

  // Edge reveal progress (sequential stagger)
  double edgeProgress(int i) {
    if (tc <= nodeEndT) return 0;
    if (tc > edgeEndT) return 1;
    final edgeT = tc - nodeEndT;
    final edgeDur = _kCycleDur * _kEdgeFrac;
    final edgeSlot = edgeDur / edges.length;
    final start = i * edgeSlot;
    final end = start + edgeSlot;
    if (edgeT < start) return 0;
    if (edgeT > end) return 1;
    return ((edgeT - start) / (end - start)).clamp(0.0, 1.0);
  }

  // Global alpha (fade out after hold)
  double globalAlpha() {
    if (tc < holdEndT) return 1.0;
    final fadeT = _kCycleDur - holdEndT;
    return (1.0 - ((tc - holdEndT) / fadeT)).clamp(0.0, 1.0);
  }

  final ga = globalAlpha();
  if (ga <= 0) return;

  // --- Project nodes -------------------------------------------------------
  final projected = nodes.map((n) {
    final p = proj(n[0], n[1], n[2]);
    return Offset(p[0], p[1]);
  }).toList();

  // --- Draw edges first (below nodes) -------------------------------------
  for (int i = 0; i < edges.length; i++) {
    final ep = edgeProgress(i);
    if (ep <= 0) continue;

    final e = edges[i];
    final np1 = nodeProgress(e.a);
    final np2 = nodeProgress(e.b);
    final bothVisible = np1 > 0.5 && np2 > 0.5;
    if (!bothVisible) continue;

    _paintEdge(
      ctx,
      projected[e.a],
      projected[e.b],
      ep,
      0.35 * ga,
      dark,
      max(0.4, o.get('rMin', 0.3)),
    );
  }

  // --- Draw node dots -------------------------------------------------------
  for (int i = 0; i < nodes.length; i++) {
    final np = nodeProgress(i);
    if (np <= 0) continue;

    final p = proj(nodes[i][0], nodes[i][1], nodes[i][2]);
    final depth = (p[2] + 1) / 2;

    // Halo (slightly larger, very transparent)
    final haloR = (o.get('rBase', 1.8) + o.get('rDepth', 2.5) * depth) * rs * 2.0;
    final haloPaint = Paint()
      ..color = Color.fromARGB(
        ((0.12 * np * ga) * 255).round().clamp(0, 255),
        dark ? 200 : 60,
        dark ? 200 : 60,
        dark ? 200 : 60,
      )
      ..style = PaintingStyle.fill;
    ctx.drawCircle(Offset(p[0], p[1]), max(0.5, haloR), haloPaint);

    // Core dot
    final coreR = (o.get('rBase', 1.8) + o.get('rDepth', 2.5) * depth) * rs;
    final w = (0.62 - 0.5 * depth).clamp(0.0, 1.0);
    final g = ((dark ? 1 - w : w) * 255).round();
    final corePaint = Paint()
      ..color = Color.fromARGB(
        ((np * ga) * 255).round().clamp(0, 255),
        g,
        g,
        g,
      )
      ..style = PaintingStyle.fill;
    ctx.drawCircle(Offset(p[0], p[1]), max(o.get('rMin', 0.3), coreR), corePaint);
  }
}
