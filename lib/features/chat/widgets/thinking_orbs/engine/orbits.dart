import 'dart:math';
import 'dart:ui';
import 'core.dart';

void drawOrbits(Canvas ctx, double size, double t, bool dark, ModeOpts o) {
  final cx = size / 2;
  final cy = size / 2;
  final R = (size / 2) * 0.82;
  final pt = makeProj(t * 0.12, 0.3, cx, cy, 1);
  final rs = radiusScale(size, o.get('rsPow', 0.6));

  final dots = <Dot>[];
  final orbitN = o.get('orbitN', 12.0).toInt();
  final ghostN = o.get('ghostN', 40.0).toInt();
  final particles = o.get('particles', 3.0).toInt();

  for (int orb = 0; orb < orbitN; orb++) {
    final h1 = hashD(orb.toDouble(), 1.7);
    final h2 = hashD(orb.toDouble(), 5.2);
    final h3 = hashD(orb.toDouble(), 8.9);
    final ro = R * (0.45 + 0.52 * h1);
    final th = h1 * 2 * pi;
    final phi = acos(2 * h2 - 1);
    
    final nx = sin(phi) * cos(th);
    final ny = cos(phi);
    final nz = sin(phi) * sin(th);
    
    double ux = -ny;
    double uy = nx;
    const double uz = 0.0;
    
    final ul = max(1e-6, sqrt(ux * ux + uy * uy));
    ux /= ul;
    uy /= ul;
    
    final vx = ny * uz - nz * uy;
    final vy = nz * ux - nx * uz;
    final vz = nx * uy - ny * ux;
    
    final speed = (0.25 + 0.55 * h3) * (h3 > 0.5 ? 1 : -1);

    for (int k = 0; k < ghostN; k++) {
      final a = (k / ghostN) * 2 * pi;
      final proj = pt(
        (ux * cos(a) + vx * sin(a)) * ro,
        (uy * cos(a) + vy * sin(a)) * ro,
        (uz * cos(a) + vz * sin(a)) * ro
      );
      
      final depth = (proj[2] / ro + 1) / 2;
      dots.add(Dot(
        x: proj[0],
        y: proj[1],
        z: proj[2],
        r: o.get('ghostR', 0.9) * rs,
        white: 0.72,
        alpha: o.get('ghostA', 0.5) * (0.4 + 0.6 * depth),
      ));
    }

    for (int m = 0; m < particles; m++) {
      final a = t * speed + (m / particles) * 2 * pi + h2 * 6;
      final proj = pt(
        (ux * cos(a) + vx * sin(a)) * ro,
        (uy * cos(a) + vy * sin(a)) * ro,
        (uz * cos(a) + vz * sin(a)) * ro
      );
      
      final depth = (proj[2] / ro + 1) / 2;
      dots.add(Dot(
        x: proj[0],
        y: proj[1],
        z: proj[2],
        r: (o.get('partR', 1.2) + o.get('partRDepth', 1.6) * depth) * rs,
        white: 0.3 - 0.22 * depth,
      ));
    }
  }
  
  paintDots(ctx, dots, dark, o.get('rMin', 0.3));
}
