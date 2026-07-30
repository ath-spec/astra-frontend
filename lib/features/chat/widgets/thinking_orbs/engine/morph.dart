import 'dart:math';
import 'dart:ui';
import 'core.dart';

typedef PathBuilder = List<double> Function(double f);

double smoothE(double x) {
  return x * x * (3 - 2 * x);
}

PathBuilder polyPath(List<List<double>> verts) {
  final int V = verts.length;
  final L = <double>[];
  double total = 0.0;
  
  for (int i = 0; i < V; i++) {
    final a = verts[i];
    final b = verts[(i + 1) % V];
    
    // Equivalent to Math.hypot(b[0] - a[0], b[1] - a[1])
    final l = sqrt(pow(b[0] - a[0], 2) + pow(b[1] - a[1], 2));
    L.add(l);
    total += l;
  }
  
  return (double f) {
    double target = f * total;
    int i = 0;
    while (target > L[i] && i < V - 1) {
      target -= L[i];
      i++;
    }
    
    final a = verts[i];
    final b = verts[(i + 1) % V];
    final ff = L[i] > 0 ? min(1.0, target / L[i]) : 0.0;
    
    return [a[0] + (b[0] - a[0]) * ff, a[1] + (b[1] - a[1]) * ff];
  };
}

final PathBuilder _circle = (double f) {
  final a = -pi / 2 + f * 2 * pi;
  return [cos(a) * 0.24, sin(a) * 0.24];
};

final PathBuilder _triangle = polyPath([
  [0.0, -0.26],
  [0.24, 0.16],
  [-0.24, 0.16]
]);

final PathBuilder _square = polyPath([
  [0.0, -0.2],
  [0.2, -0.2],
  [0.2, 0.2],
  [-0.2, 0.2],
  [-0.2, -0.2]
]);

final List<PathBuilder> _cycle = [_circle, _triangle, _square];

int morphN(double d) {
  return max(6, (34 * d).round());
}

const double HOLD = 1.4;
const double MORPH = 0.9;
const double SEG = HOLD + MORPH;

void drawMorph(Canvas ctx, double size, double t, bool dark, ModeOpts o) {
  final K = _cycle.length;
  final tc = t % (SEG * K);
  final k = (tc / SEG).floor();
  final local = tc - k * SEG;
  final m = local > HOLD ? smoothE((local - HOLD) / MORPH) : 0.0;
  final sprd = o.get('spread', 1.0);

  final pA = _cycle[k];
  final pB = _cycle[(k + 1) % K];
  const int M = 160;
  final pts = <List<double>>[];
  
  for (int i = 0; i < M; i++) {
    final f = i / M;
    final a = pA(f);
    final b = pB(f);
    pts.add([
      (a[0] + (b[0] - a[0]) * m) * sprd,
      (a[1] + (b[1] - a[1]) * m) * sprd
    ]);
  }
  
  final L = <double>[];
  double total = 0.0;
  for (int i = 0; i < M; i++) {
    final a = pts[i];
    final b = pts[(i + 1) % M];
    final l = sqrt(pow(b[0] - a[0], 2) + pow(b[1] - a[1], 2));
    L.add(l);
    total += l;
  }

  final n = morphN(o.get('iconD', 1.0));
  final re = o.get('rDot', 0.021) * 1.35 * sprd;
  final pulse = 1.0 + 0.02 * sin(local * 3.1);

  final dots = <Dot>[];
  final c2 = size / 2;
  int seg = 0;
  double acc = 0.0;
  
  for (int k2 = 0; k2 < n; k2++) {
    final target = (k2 / n) * total;
    while (acc + L[seg] < target && seg < M - 1) {
      acc += L[seg];
      seg++;
    }
    
    final a = pts[seg];
    final b = pts[(seg + 1) % M];
    final f = L[seg] > 0 ? min(1.0, (target - acc) / L[seg]) : 0.0;
    
    final x = (a[0] + (b[0] - a[0]) * f) * pulse;
    final y = (a[1] + (b[1] - a[1]) * f) * pulse;
    
    dots.add(Dot(
      x: c2 + x * size,
      y: c2 + y * size,
      z: 0.0,
      r: max(0.35, re * size),
      white: 0.1,
    ));
  }
  
  paintDots(ctx, dots, dark, o.get('rMin', 0.3));
}
