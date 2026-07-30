import 'dart:math';
import 'dart:ui';
import 'core.dart';

void drawRibbon(Canvas ctx, double size, double t, bool dark, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.82;
  final pt = makeProj(
    t * o.get('spin', 0.0), 
    0.35 + 0.1 * sin(t * 0.9), 
    cx, cy, R
  );
  
  final rs = radiusScale(size, o.get('rsPow', 0.6));
  final dots = <Dot>[];
  
  final lanes = o.get('lanes', 5.0).toInt();
  final segs = o.get('segs', 88.0).toInt();
  final ghostN = o.get('ghostN', 150.0).toInt();
  final bandMul = o.get('bandMul', 3.9);
  final wobMul = o.get('wobMul', 1.0);
  
  for (int i = 0; i < ghostN; i++) {
    final f = i / ghostN;
    final a = f * 2 * pi;
    final w = sin(a * 3 + t * bandMul) * 0.15 * wobMul;
    
    final x = cos(a) * (1 - w);
    final y = sin(a) * (1 - w);
    final z = w * 2;
    
    final proj = pt(x, y, z);
    final depth = (proj[2] / R + 1) / 2;
    
    dots.add(Dot(
      x: proj[0],
      y: proj[1],
      z: proj[2],
      r: (o.get('rBase', 1.1) + o.get('rDepth', 1.7) * depth) * rs * 0.5,
      white: 0.62 - 0.54 * depth,
      alpha: 0.3,
    ));
  }
  
  for (int l = 0; l < lanes; l++) {
    final lf = l / max(1, lanes - 1);
    final off = (lf - 0.5) * 0.3;
    
    for (int s = 0; s < segs; s++) {
      final sf = s / segs;
      final a = sf * 2 * pi;
      final wave = sin(a * 3 + t * bandMul);
      final w = wave * 0.15 * wobMul;
      
      final rLane = 1 - w + off * cos(a * 1.5);
      final zLane = w * 2 + off * sin(a * 1.5);
      
      final x = cos(a) * rLane;
      final y = sin(a) * rLane;
      final z = zLane;
      
      final proj = pt(x, y, z);
      final depth = (proj[2] / R + 1) / 2;
      
      dots.add(Dot(
        x: proj[0],
        y: proj[1],
        z: proj[2],
        r: (o.get('rBase', 1.1) + o.get('rDepth', 1.7) * depth) * rs,
        white: 0.62 - 0.54 * depth,
      ));
    }
  }
  
  paintDots(ctx, dots, dark, o.get('rMin', 0.3));
}
