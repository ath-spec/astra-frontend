import 'dart:math';
import 'dart:ui';
import 'core.dart';
import 'profiles.dart';

class Move {
  final int axis;
  final double lo;
  final double hi;
  final double ang;

  Move(this.axis, this.lo, this.hi, this.ang);
}

class SolveCycle {
  final List<double> amount;
  final int active;

  SolveCycle(this.amount, this.active);
}

SolveCycle solveCycle(double time, int count, double slotDur, double rest) {
  final cyc = 2 * count * slotDur + rest;
  final tc = time % cyc;
  final amount = List<double>.filled(count, 0.0);
  int active = -1;

  if (tc < 2 * count * slotDur) {
    final slot = (tc / slotDur).floor();
    final p = (tc - slot * slotDur) / slotDur;
    final cl = min(1.0, p / 0.7);
    final ep = 1.0 - powDouble(1.0 - cl, 3); 

    if (slot < count) {
      for (int i = 0; i < slot; i++) {
        amount[i] = 1.0;
      }
      amount[slot] = ep;
      active = slot;
    } else {
      final u = 2 * count - 1 - slot;
      for (int i = 0; i < u; i++) {
        amount[i] = 1.0;
      }
      amount[u] = 1.0 - ep;
      active = u;
    }
  }
  return SolveCycle(amount, active);
}

class ApplyMovesResult {
  final double x;
  final double y;
  final double z;
  final bool inActive;

  ApplyMovesResult(this.x, this.y, this.z, this.inActive);
}

ApplyMovesResult applyMoves(
  List<double> pt3,
  List<Move> moves,
  SolveCycle sc,
) {
  double x = pt3[0];
  double y = pt3[1];
  double z = pt3[2];
  bool inActive = false;

  for (int i = 0; i < moves.length; i++) {
    if (sc.amount[i] <= 0) continue;
    final mv = moves[i];
    final coord = mv.axis == 0 ? x : mv.axis == 1 ? y : z;

    if (coord < mv.lo || coord >= mv.hi) continue;
    if (i == sc.active) inActive = true;

    final a = mv.ang * sc.amount[i];
    final ca = cos(a);
    final sa = sin(a);

    if (mv.axis == 0) {
      final y2 = y * ca - z * sa;
      z = y * sa + z * ca;
      y = y2;
    } else if (mv.axis == 1) {
      final x2 = x * ca + z * sa;
      z = -x * sa + z * ca;
      x = x2;
    } else {
      final x2 = x * ca - y * sa;
      y = x * sa + y * ca;
      x = x2;
    }
  }

  return ApplyMovesResult(x, y, z, inActive);
}

List<Move> makeMoves(int count) {
  final moves = <Move>[];
  for (int i = 0; i < count; i++) {
    final axis = min(2, (hashD(i.toDouble(), 2.3) * 3).floor());
    final lo = -1.0 + 0.5 * min(3, (hashD(i.toDouble(), 5.9) * 4).floor());
    final dir = hashD(i.toDouble(), 7.7) < 0.5 ? 1.0 : -1.0;
    moves.add(Move(axis, lo, lo + 0.5, (dir * pi) / 2));
  }
  return moves;
}

void drawRubik(Canvas ctx, double size, double t, bool dark, ModeOpts o, [Color? color]) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.82;
  final pt = makeProj(t * 0.55, 0.35 + 0.1 * sin(t * 0.9), cx, cy, R);
  final rs = radiusScale(size, o.get('rsPow', 0.6));
  final moveCount = o.get('moveCount', 14.0).toInt();
  final moves = makeMoves(moveCount);
  final sc = solveCycle(t, moveCount, 0.42, 1.2);

  final dots = <Dot>[];
  final latRings = o.get('latRings', 15.0).toInt();
  final lonDensity = o.get('lonDensity', 40.0).toInt();

  for (int li = 0; li <= latRings; li++) {
    final lat = -pi / 2 + (li / latRings) * pi;
    final cosLat = cos(lat);
    final sinLat = sin(lat);
    final lonCount = max(1, (cosLat.abs() * lonDensity).round());

    for (int lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * pi;
      
      final res = applyMoves(
        [cosLat * cos(lon), sinLat, cosLat * sin(lon)],
        moves,
        sc,
      );
      
      final proj = pt(res.x, res.y, res.z);
      final px = proj[0];
      final py = proj[1];
      final zr = proj[2];
      
      final depth = (zr + 1) / 2;
      
      dots.add(Dot(
        x: px,
        y: py,
        z: zr,
        r: (o.get('rBase', 0.6) + o.get('rDepth', 1.7) * depth + (res.inActive ? o.get('rActive', 0.3) : 0)) * rs,
        white: o.get('inkFar', 0.62) - o.get('inkSpan', 0.54) * depth - (res.inActive ? 0.14 : 0),
      ));
    }
  }

  paintDots(ctx, dots, dark, o.get('rMin', 0.3), color);
}

void drawGlobe(Canvas ctx, double size, double t, bool dark, ModeOpts o, [Color? color]) {
  const spin = 0.5;
  final cx = size / 2;
  final cy = size / 2;
  final radius = (size / 2) * 0.82;
  final tilt = 0.4 + 0.06 * sin(t * 0.35);
  final pt = makeProj(t * spin, tilt, cx, cy, radius);
  
  final scan = t * (spin + (1.7 - spin) * o.get('scanMul', 1.0));
  final rs = radiusScale(size, o.get('rsPow', 0.6));
  final dimBase = o.get('dimBase', 1.0);

  final dots = <Dot>[];
  final latRings = o.get('latRings', 17.0).toInt();
  final lonDensity = o.get('lonDensity', 44.0).toInt();
  
  for (int li = 0; li <= latRings; li++) {
    final lat = -pi / 2 + (li / latRings) * pi;
    final cosLat = cos(lat);
    final sinLat = sin(lat);
    final lonCount = max(1, (cosLat.abs() * lonDensity).round());
    
    for (int lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * pi;
      final proj = pt(cosLat * cos(lon), sinLat, cosLat * sin(lon));
      final z = proj[2];
      final depth = (z + 1) / 2;
      
      final d = angleDelta(lon + t * spin, scan);
      final boost = exp(-(d * d) / 0.18) * max(0.0, z);
      
      dots.add(Dot(
        x: proj[0],
        y: proj[1],
        z: z,
        r: (o.get('rBase', 0.6) + o.get('rDepth', 1.7) * depth + o.get('rBoost', 1.0) * boost) * rs,
        white: o.get('inkFar', 0.62) - o.get('inkSpan', 0.54) * depth,
        alpha: dimBase + (1 - dimBase) * min(1.0, boost),
      ));
    }
  }
  
  paintDots(ctx, dots, dark, o.get('rMin', 0.3));
}

void drawWave(Canvas ctx, double size, double t, bool dark, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.874;
  final pt = makeProj(t * 0.18, 0.38, cx, cy, 1);
  final rs = radiusScale(size, o.get('rsPow', 0.6));

  final dots = <Dot>[];
  final rings = o.get('rings', 15.0).toInt();
  final lonDensity = o.get('lonDensity', 40.0).toInt();
  
  for (int ri = 0; ri <= rings; ri++) {
    final lat = -pi / 2 + (ri / rings) * pi;
    final cosLat = cos(lat);
    final sinLat = sin(lat);
    
    final w = 0.62 * sin(t * 2.1 - ri * 0.52) + 0.38 * sin(t * 1.27 + ri * 0.83);
    final rr = R * (0.88 + 0.105 * w);
    final lonCount = max(1, (cosLat.abs() * lonDensity).round());
    
    for (int lj = 0; lj < lonCount; lj++) {
      final lon = (lj / lonCount) * 2 * pi;
      final proj = pt(cosLat * cos(lon) * rr, sinLat * rr, cosLat * sin(lon) * rr);
      final z = proj[2];
      final depth = (z / R + 1) / 2;
      final crest = max(0.0, w);
      
      dots.add(Dot(
        x: proj[0],
        y: proj[1],
        z: z,
        r: (o.get('rBase', 0.6) + o.get('rDepth', 1.7) * depth) * (1 + 0.4 * crest) * rs,
        white: 0.66 - 0.56 * depth - 0.1 * crest,
      ));
    }
  }
  
  paintDots(ctx, dots, dark, o.get('rMin', 0.3));
}
