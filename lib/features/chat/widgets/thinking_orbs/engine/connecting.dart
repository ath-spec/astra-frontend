import 'dart:math';
import 'dart:ui';
import 'core.dart';

class Line {
  final double x1, y1, x2, y2, white, a, w;
  Line({
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.white,
    required this.a,
    required this.w,
  });
}

double frac(double x) => x - x.floorToDouble();

double lerp(double a, double b, double t) => a + (b - a) * t;

// A simple value noise based on hashD
double vnoise(double x, double y) {
  final ix = x.floorToDouble();
  final iy = y.floorToDouble();
  final fx = frac(x);
  final fy = frac(y);
  
  // Smoothstep
  final sx = fx * fx * (3.0 - 2.0 * fx);
  final sy = fy * fy * (3.0 - 2.0 * fy);
  
  final v00 = hashD(ix, iy);
  final v10 = hashD(ix + 1.0, iy);
  final v01 = hashD(ix, iy + 1.0);
  final v11 = hashD(ix + 1.0, iy + 1.0);
  
  final vx0 = lerp(v00, v10, sx);
  final vx1 = lerp(v01, v11, sx);
  
  return lerp(vx0, vx1, sy);
}

void paintLines(Canvas ctx, List<Line> lines, bool dark, [Color? customColor]) {
  for (final l in lines) {
    if (l.a < 0.02) continue;
    final w = l.white.clamp(0.0, 1.0);
    final g = ((dark ? 1 - w : w) * 255).round();
    final Color baseColor = customColor ?? Color.fromARGB(255, g, g, g);
    final paint = Paint()
      ..color = baseColor.withValues(alpha: l.a)
      ..strokeWidth = l.w
      ..style = PaintingStyle.stroke;
    ctx.drawLine(Offset(l.x1, l.y1), Offset(l.x2, l.y2), paint);
  }
}

void drawConnecting(Canvas ctx, double size, double t, bool dark, ModeOpts o, [Color? color]) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.8 * o.get('spread', 1.0);
  
  // note the projector carries the radius as its scale, so node vectors stay
  // unit-length and distances below are in unit-sphere space
  final pt = makeProj(t * 0.12, 0.32, cx, cy, R);
  final rs = radiusScale(size, o.get('rsPow', 0.6));

  final int nodeN = o.get('nodeN', 30.0).toInt();
  final thr = o.get('thr', 0.72);
  final nodeR = o.get('nodeR', 1.4);
  final nodeRDepth = o.get('nodeRDepth', 1.8);

  // nodes: fib lattice + slow noise wander, renormalised to the surface
  final List<List<double>> nodes = [];
  for (int i = 0; i < nodeN; i++) {
    final d = fibDir(i, nodeN);
    final x = d[0] + 0.3 * (vnoise(i * 0.31 + 9, t * 0.24) - 0.5) * 2;
    final y = d[1] + 0.3 * (vnoise(i * 0.53 + 27, t * 0.21) - 0.5) * 2;
    final z = d[2] + 0.3 * (vnoise(i * 0.77 + 55, t * 0.27) - 0.5) * 2;
    final l = max(1e-6, sqrt(x * x + y * y + z * z));
    nodes.add([x / l, y / l, z / l]);
  }

  final List<Line> lines = [];
  final List<Dot> dots = [];

  // edges between close neighbours, alpha by proximity + depth
  for (int i = 0; i < nodeN; i++) {
    for (int j = i + 1; j < nodeN; j++) {
      final dx = nodes[i][0] - nodes[j][0];
      final dy = nodes[i][1] - nodes[j][1];
      final dz = nodes[i][2] - nodes[j][2];
      final dist = sqrt(dx * dx + dy * dy + dz * dz);
      if (dist >= thr) continue;
      
      final p1 = pt(nodes[i][0], nodes[i][1], nodes[i][2]);
      final p2 = pt(nodes[j][0], nodes[j][1], nodes[j][2]);
      
      final depth = ((p1[2] + p2[2]) / 2 + 1) / 2;
      lines.add(Line(
        x1: p1[0],
        y1: p1[1],
        x2: p2[0],
        y2: p2[1],
        white: 0.42,
        a: (1 - dist / thr) * (0.3 + 0.55 * depth),
        w: max(0.6, o.get('lineW', 0.8) * rs)
      ));
    }
  }

  for (int i = 0; i < nodeN; i++) {
    final p = pt(nodes[i][0], nodes[i][1], nodes[i][2]);
    final depth = (p[2] + 1) / 2;
    final pulse = 1 + 0.25 * sin(t * 1.4 + i * 2.7);
    dots.add(Dot(
      x: p[0],
      y: p[1],
      z: p[2],
      r: (nodeR + nodeRDepth * depth) * pulse * rs,
      white: 0.55 - 0.45 * depth
    ));
  }

  // signals: bright packets running between paired nodes
  final int signals = o.get('signals', 5.0).toInt();
  for (int s = 0; s < signals; s++) {
    final seg = (t * 0.55 + s * 7.31).floorToDouble();
    final a = (hashD(seg, s * 3.1 + 1.7) * nodeN).floor().clamp(0, nodeN - 1);
    final b = (hashD(seg, s * 5.7 + 4.2) * nodeN).floor().clamp(0, nodeN - 1);
    if (a == b) continue;
    
    final f = frac(t * 0.55 + s * 7.31);
    final x = lerp(nodes[a][0], nodes[b][0], f);
    final y = lerp(nodes[a][1], nodes[b][1], f);
    final z = lerp(nodes[a][2], nodes[b][2], f);
    final l = max(1e-6, sqrt(x * x + y * y + z * z));
    
    final p = pt(x / l, y / l, z / l);
    final depth = (p[2] + 1) / 2;
    dots.add(Dot(
      x: p[0],
      y: p[1],
      z: p[2],
      r: (nodeR * 1.5 + nodeRDepth * depth) * rs,
      white: 0.05,
      alpha: 0.5 + 0.5 * depth
    ));
  }

  paintLines(ctx, lines, dark, color);
  paintDots(ctx, dots, dark, o.get('rMin', 0.3), color);
}
