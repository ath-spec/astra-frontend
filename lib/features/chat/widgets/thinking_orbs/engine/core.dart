import 'dart:math';
import 'dart:ui';

class Dot {
  double x;
  double y;
  double z;
  double r;
  double white;
  double alpha;

  Dot({
    required this.x,
    required this.y,
    required this.z,
    required this.r,
    required this.white,
    this.alpha = 1.0,
  });
}

class ModeOpts {
  final Map<String, double> _data;
  
  ModeOpts(this._data);
  
  double? operator [](String key) => _data[key];
  void operator []=(String key, double value) => _data[key] = value;
  
  double get(String key, double defaultValue) => _data[key] ?? defaultValue;
  
  ModeOpts copy() => ModeOpts(Map.from(_data));
}

typedef ModeDraw = void Function(
  Canvas canvas,
  double size,
  double t,
  bool dark,
  ModeOpts opts,
);

typedef Projector = List<double> Function(double x, double y, double z);

double hashD(double a, double b) {
  final h = sin(a * 12.9898 + b * 78.233) * 43758.5453;
  return h - h.floorToDouble();
}

List<double> fibDir(int i, int n) {
  final golden = pi * (3 - sqrt(5));
  final y = 1 - (2 * (i + 0.5)) / n;
  final rad = sqrt(1 - y * y);
  final a = i * golden;
  return [rad * cos(a), y, rad * sin(a)];
}

double angleDelta(double a, double b) {
  return atan2(sin(a - b), cos(a - b));
}

Projector makeProj(double yaw, double tilt, double cx, double cy, double scale) {
  final st = sin(tilt);
  final ct = cos(tilt);
  final sy = sin(yaw);
  final cyw = cos(yaw);
  
  return (double x, double y, double z) {
    final x1 = x * cyw + z * sy;
    final z1 = -x * sy + z * cyw;
    final y1 = y * ct - z1 * st;
    final z2 = y * st + z1 * ct;
    return [cx + x1 * scale, cy - y1 * scale, z2];
  };
}

void paintDots(Canvas canvas, List<Dot> dots, bool dark, [double rMin = 0.3]) {
  dots.sort((a, b) => a.z.compareTo(b.z));
  for (final d in dots) {
    if (d.alpha < 0.02) continue;
    final w = d.white.clamp(0.0, 1.0);
    final g = ((dark ? 1 - w : w) * 255).round();
    
    final paint = Paint()
      ..color = Color.fromARGB((d.alpha * 255).round(), g, g, g)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(d.x, d.y), max(rMin, d.r), paint);
  }
}

double radiusScale(double size, double powVal) {
  return pow(size / 300, powVal).toDouble();
}

double powDouble(double base, double exponent) {
  return pow(base, exponent).toDouble();
}
