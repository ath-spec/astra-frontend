import 'dart:math';
import 'core.dart';

final List<List<String>> countPairs = [
  ['latRings', 'lonDensity'],
  ['rings', 'lonDensity'],
  ['lanes', 'segs']
];

final List<String> countKeys = ['orbitN', 'ghostN'];
final List<String> iconDensityKeys = ['iconD'];

final List<String> radiusKeys = [
  'rBase', 'rDepth', 'rActive', 'rDot', 'ghostR', 'partR', 'partRDepth'
];

ModeOpts scaleCounts(ModeOpts opts, double scale) {
  final out = opts.copy();
  final done = <String>{};
  final rt = sqrt(scale);

  for (final pair in countPairs) {
    final a = pair[0];
    final b = pair[1];
    final va = out[a];
    final vb = out[b];
    
    if (va != null && vb != null && !done.contains(a) && !done.contains(b)) {
      out[a] = max(2.0, (va * rt).roundToDouble());
      out[b] = max(2.0, (vb * rt).roundToDouble());
      done.add(a);
      done.add(b);
    }
  }

  for (final k in countKeys) {
    final v = out[k];
    if (v != null && !done.contains(k)) {
      out[k] = max(1.0, (v * scale).roundToDouble());
    }
  }

  for (final k in iconDensityKeys) {
    final v = out[k];
    if (v != null) {
      out[k] = max(0.02, v * scale);
    }
  }
  
  return out;
}

ModeOpts scaleRadii(ModeOpts opts, double scale) {
  final out = opts.copy();
  
  for (final k in radiusKeys) {
    final v = out[k];
    if (v != null) {
      out[k] = v * scale;
    }
  }
  
  out['rSizeMul'] = (out.get('rSizeMul', 1.0)) * scale;
  
  return out;
}

final Map<String, ModeOpts> baseProfiles = {
  'globe': ModeOpts({
    'latRings': 17,
    'lonDensity': 44,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rBoost': 1.0,
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'rsPow': 0.6,
    'rMin': 0.3
  }),
  'orbits': ModeOpts({
    'orbitN': 12,
    'ghostN': 40,
    'ghostR': 0.9,
    'ghostA': 0.5,
    'particles': 3,
    'partR': 1.2,
    'partRDepth': 1.6,
    'rsPow': 0.6,
    'rMin': 0.3
  }),
  'rubik': ModeOpts({
    'latRings': 15,
    'lonDensity': 40,
    'moveCount': 14,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rActive': 0.3,
    'inkFar': 0.62,
    'inkSpan': 0.54,
    'rsPow': 0.6,
    'rMin': 0.3
  }),
  'wave': ModeOpts({
    'rings': 15,
    'lonDensity': 40,
    'rBase': 0.6,
    'rDepth': 1.7,
    'rsPow': 0.6,
    'rMin': 0.3
  }),
  'ribbon': ModeOpts({
    'lanes': 5,
    'segs': 88,
    'ghostN': 150,
    'rBase': 1.1,
    'rDepth': 1.7,
    'rsPow': 0.6,
    'rMin': 0.3
  }),
  'morph': ModeOpts({
    'rDot': 0.021,
    'iconD': 1,
    'rMin': 0.25
  }),
  'connecting': ModeOpts({
    'rBase': 1.8,
    'rDepth': 2.5,
    'rsPow': 0.6,
    'rMin': 0.4
  })
};
