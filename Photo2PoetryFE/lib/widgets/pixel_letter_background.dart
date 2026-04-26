import 'dart:math';
import 'package:flutter/material.dart';

/// Shared animated background: RGB pixel squares flicker into letters,
/// visualising the metaphor of a photo dissolving into a poem.
class PixelLetterBackground extends StatefulWidget {
  const PixelLetterBackground({super.key});

  @override
  State<PixelLetterBackground> createState() => _PixelLetterBackgroundState();
}

class _Cell {
  Color color;
  bool isLetter;
  String letter;
  double opacity;

  _Cell({
    required this.color,
    required this.isLetter,
    required this.letter,
    required this.opacity,
  });
}

class _PixelLetterBackgroundState extends State<PixelLetterBackground>
    with SingleTickerProviderStateMixin {
  static const double _cellSize = 18.0;
  static const double _gap = 2.0;
  static const double _stride = _cellSize + _gap;

  static const _letters = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  final _random = Random();
  List<_Cell> _cells = [];
  int _cols = 0;
  int _rows = 0;
  bool _gridBuilt = false;

  late AnimationController _ticker;
  int _frameCount = 0;

  @override
  void initState() {
    super.initState();
    _ticker =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 16),
          )
          ..addListener(_onTick)
          ..repeat();
  }

  void _buildGrid(Size size) {
    _cols = (size.width / _stride).ceil() + 1;
    _rows = (size.height / _stride).ceil() + 1;
    final count = _cols * _rows;
    if (_cells.length == count && _gridBuilt) return;
    _gridBuilt = true;
    _cells = List.generate(
      count,
      (_) => _Cell(
        color: _randomColor(),
        isLetter: _random.nextBool(),
        letter: _letters[_random.nextInt(_letters.length)],
        opacity: _random.nextDouble() * 0.55 + 0.15,
      ),
    );
  }

  Color _randomColor() {
    final hue = _random.nextDouble() * 360;
    return HSVColor.fromAHSV(1.0, hue, 0.85, 0.95).toColor();
  }

  void _onTick() {
    _frameCount++;
    if (_frameCount % 8 != 0 || _cells.isEmpty) {
      setState(() {});
      return;
    }
    final mutCount = max(2, (_cells.length * 0.03).round());
    for (int i = 0; i < mutCount; i++) {
      final idx = _random.nextInt(_cells.length);
      final cell = _cells[idx];
      cell.isLetter = !cell.isLetter;
      if (!cell.isLetter) cell.color = _randomColor();
      cell.letter = _letters[_random.nextInt(_letters.length)];
      cell.opacity = _random.nextDouble() * 0.55 + 0.15;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _buildGrid(Size(constraints.maxWidth, constraints.maxHeight));
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _GridPainter(
            cells: _cells,
            cols: _cols,
            stride: _stride,
            cellSize: _cellSize,
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final List<_Cell> cells;
  final int cols;
  final double stride;
  final double cellSize;

  static final _tp = TextPainter(textDirection: TextDirection.ltr);

  _GridPainter({
    required this.cells,
    required this.cols,
    required this.stride,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < cells.length; i++) {
      final cell = cells[i];
      final col = i % cols;
      final row = i ~/ cols;
      final dx = col * stride;
      final dy = row * stride;
      final color = cell.color.withValues(alpha: cell.opacity);

      if (!cell.isLetter) {
        paint.color = color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(dx, dy, cellSize, cellSize),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        _tp
          ..text = TextSpan(
            text: cell.letter,
            style: TextStyle(
              color: color,
              fontSize: cellSize * 0.85,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          )
          ..layout();
        _tp.paint(
          canvas,
          Offset(
            dx + (cellSize - _tp.width) / 2,
            dy + (cellSize - _tp.height) / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => true;
}

/// Standard vignette overlay – darkens edges, lets centre breathe.
/// Wrap around [PixelLetterBackground] inside a [Stack].
class VignetteOverlay extends StatelessWidget {
  final Color baseColor;
  const VignetteOverlay({super.key, this.baseColor = const Color(0xFF0E0C14)});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.97,
          colors: [
            baseColor.withValues(alpha: 0.40),
            baseColor.withValues(alpha: 0.70),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}
