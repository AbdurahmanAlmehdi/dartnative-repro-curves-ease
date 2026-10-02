import 'package:dartnative/dartnative.dart';

import 'dartnative_plugin_registrant.dart';

void main() {
  DartNativePluginRegistrant.registerAll();
  runApp(const CurvesEaseRepro());
}

const _ink = TextStyle(fontSize: 14, color: Color(0xFF111111));
const _red = TextStyle(fontSize: 14, color: Color(0xFFC62828));
const _cell = TextStyle(fontSize: 15, color: Color(0xFF111111), fontFeatures: [FontFeature.tabularFigures()]);
const _cellHead = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF111111));

/// Flutter's `Cubic` (same bisection, same 0.001 error bound). DartNative has
/// no `Cubic`, so the reference values are computed here.
class FlutterCubic extends Curve {
  const FlutterCubic(this.a, this.b, this.c, this.d);
  final double a, b, c, d;

  double _evaluate(double p1, double p2, double m) =>
      3 * p1 * (1 - m) * (1 - m) * m + 3 * p2 * (1 - m) * m * m + m * m * m;

  @override
  double transform(double t) {
    var start = 0.0;
    var end = 1.0;
    while (true) {
      final mid = (start + end) / 2;
      final estimate = _evaluate(a, c, mid);
      if ((t - estimate).abs() < 0.001) return _evaluate(b, d, mid);
      if (estimate < t) {
        start = mid;
      } else {
        end = mid;
      }
    }
  }
}

const _flutterEase = FlutterCubic(0.25, 0.1, 0.25, 1.0);
const _ts = [0.1, 0.25, 0.5, 0.75];

class CurvesEaseRepro extends StatelessWidget {
  const CurvesEaseRepro({super.key});

  Widget _cellText(String s, TextStyle style, {Color? bg}) => Expanded(
        child: Container(
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: Alignment.centerRight,
          child: Text(s, style: style),
        ),
      );

  @override
  Widget build(BuildContext context) {
    String f(double v) => v.toStringAsFixed(4);
    return Scaffold(
      brightness: Brightness.light,
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: const Text('Curves.ease is easeInOut')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expected (Flutter): Curves.ease == Cubic(0.25, 0.1, 0.25, 1.0), '
              'a fast start and long ease-out.',
              style: _ink,
            ),
            const SizedBox(height: 4),
            const Text(
              'Actual: Curves.ease returns the same values as Curves.easeInOut. '
              'DartNative has no Cubic class, so the last column is Flutter\'s '
              'Cubic algorithm copied into this app.',
              style: _red,
            ),
            const SizedBox(height: 8),
            const Text('Flutter ease = Cubic(0.25, 0.1, 0.25, 1.0).transform(t)', style: _ink),
            const SizedBox(height: 8),
            Row(children: [
              _cellText('t', _cellHead),
              _cellText('Curves\n.ease', _cellHead),
              _cellText('Curves\n.easeInOut', _cellHead),
              _cellText('Flutter ease\n(Cubic)', _cellHead),
            ]),
            for (final t in _ts)
              Row(children: [
                _cellText(t.toString(), _cell),
                _cellText(f(Curves.ease.transform(t)), _cell, bg: const Color(0xFFFFEBEE)),
                _cellText(f(Curves.easeInOut.transform(t)), _cell),
                _cellText(f(_flutterEase.transform(t)), _cell, bg: const Color(0xFFE8F5E9)),
              ]),
          ],
        ),
      ),
    );
  }
}
