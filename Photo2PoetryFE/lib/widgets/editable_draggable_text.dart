import 'dart:math';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';
import '../app_theme.dart';

class EditableDraggableText extends StatefulWidget {
  final String initialText;
  final Widget backgroundLayer;
  final double imageAspectRatio;
  final ScreenshotController screenshotController;
  final Function(String) onTextChanged;

  const EditableDraggableText({
    super.key,
    required this.initialText,
    required this.backgroundLayer,
    required this.imageAspectRatio,
    required this.screenshotController,
    required this.onTextChanged,
  });

  @override
  State<EditableDraggableText> createState() => _EditableDraggableTextState();
}

class _EditableDraggableTextState extends State<EditableDraggableText> {
  Offset _position = const Offset(0, 0);
  double _fontSizeBase = 22.0;
  double _fontScale = 1.0;
  double _rotationAngle = 0.0;

  Color _textColor = Colors.white;
  bool _showBackground = true;
  TextAlign _textAlign = TextAlign.center;
  late TextEditingController _textController;

  double _boxWidthRatio =
      0.95; // Stretches wider initially so text doesn't crimp
  bool _initialPositionSet = false;

  // New Styling Controls
  double _bgOpacity = 0.6;
  double _padding = 12.0;
  bool _showStyleControls = false;

  final List<String> _fontOptions = [
    'Space Grotesk',
    'Roboto',
    'Press Start 2P',
    'Pacifico',
    'Orbitron',
    'Cinzel',
  ];
  late String _currentFont;

  @override
  void initState() {
    super.initState();
    _currentFont = _fontOptions[0];
    _textController = TextEditingController(text: widget.initialText);

    // Smart initial font sizing
    _calculateInitialFontSize();
  }

  void _calculateInitialFontSize() {
    final text = widget.initialText;
    final length = text.length;

    // Heuristic: adjust starting size based on total characters
    if (length < 100) {
      _fontSizeBase = 26.0;
    } else if (length < 300) {
      _fontSizeBase = 22.0;
    } else if (length < 600) {
      _fontSizeBase = 18.0;
    } else {
      _fontSizeBase = 15.0;
    }

    // Also consider line density
    final lines = text.split('\n').length;
    if (lines > 12 && _fontSizeBase > 18) {
      _fontSizeBase = 18.0;
    }
    if (lines > 20 && _fontSizeBase > 14) {
      _fontSizeBase = 14.0;
    }
  }

  @override
  void didUpdateWidget(EditableDraggableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      if (_textController.text != widget.initialText) {
        _textController.text = widget.initialText;
        _calculateInitialFontSize();
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _constrainPosition(Size canvasSize) {
    if (canvasSize.width == 0) return;

    final boxW = canvasSize.width * _boxWidthRatio;

    if (!_initialPositionSet) {
      _position = Offset(
        (canvasSize.width - boxW) / 2, // Centered horizontally
        canvasSize.height * 0.15, // 15% from top
      );
      _initialPositionSet = true;
    } else {
      double newX = _position.dx;
      double newY = _position.dy;

      // Final clamping to screen edges
      newX = newX.clamp(0.0, max(0.0, canvasSize.width - boxW));
      newY = newY.clamp(0.0, max(0.0, canvasSize.height - 50.0));
      _position = Offset(newX, newY);
    }
  }

  TextStyle _getTextStyle() {
    TextStyle baseStyle = GoogleFonts.getFont(_currentFont).copyWith(
      color: _textColor,
      fontSize: (_fontSizeBase * _fontScale).roundToDouble(),
      shadows: _showBackground
          ? []
          : const [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            ],
    );
    return baseStyle;
  }

  void _toggleAlignment() {
    setState(() {
      switch (_textAlign) {
        case TextAlign.left:
          _textAlign = TextAlign.center;
          break;
        case TextAlign.center:
          _textAlign = TextAlign.right;
          break;
        case TextAlign.right:
          _textAlign = TextAlign.justify;
          break;
        case TextAlign.justify:
          _textAlign = TextAlign.left;
          break;
        default:
          _textAlign = TextAlign.center;
      }
    });
  }

  IconData _getAlignmentIcon() {
    switch (_textAlign) {
      case TextAlign.left:
        return Icons.format_align_left;
      case TextAlign.center:
        return Icons.format_align_center;
      case TextAlign.right:
        return Icons.format_align_right;
      case TextAlign.justify:
        return Icons.format_align_justify;
      default:
        return Icons.format_align_center;
    }
  }

  void _showColorPicker() {
    Color tempColor = _textColor;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kInkSurface,
          title: Text(
            'Pick Text Color',
            style: kTitleStyle(20).copyWith(color: kParchment),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _textColor,
              onColorChanged: (color) => tempColor = color,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: kBodyStyle(14, color: kMuted)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kInk,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Apply'),
              onPressed: () {
                setState(() => _textColor = tempColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTextDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kInkSurface,
          title: Text(
            'Edit Poem',
            style: kTitleStyle(20).copyWith(color: kParchment),
          ),
          content: TextField(
            controller: _textController,
            maxLines: 8,
            minLines: 3,
            style: kBodyStyle(14, color: kParchment),
            decoration: InputDecoration(
              filled: true,
              fillColor: kInk,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kRose.withValues(alpha: 0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kGold, width: 2),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kGold,
                foregroundColor: kInk,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Save Changes',
                style: kMonoStyle(
                  12,
                  color: kInk,
                ).copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                setState(() {}); // Trigger rebuild
                widget.onTextChanged(_textController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- SCREENSHOT BOUNDARY ---
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Screenshot(
                controller: widget.screenshotController,
                child: AspectRatio(
                  aspectRatio: widget.imageAspectRatio,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _constrainPosition(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      );
                      final boxWidth = constraints.maxWidth * _boxWidthRatio;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          widget.backgroundLayer,

                          // Optional Scrim
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 200,
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.black54, Colors.transparent],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: _position.dx,
                            top: _position.dy,
                            child: GestureDetector(
                              onPanUpdate: (details) {
                                setState(() {
                                  _position += details.delta;
                                  _constrainPosition(
                                    Size(
                                      constraints.maxWidth,
                                      constraints.maxHeight,
                                    ),
                                  );
                                });
                              },
                              child: Transform.rotate(
                                angle: _rotationAngle,
                                child: Container(
                                  width: boxWidth,
                                  decoration: BoxDecoration(
                                    color: _showBackground
                                        ? Colors.black.withValues(
                                            alpha: _bgOpacity,
                                          )
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: _showBackground
                                        ? [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 10,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(_padding),
                                    child: AutoSizeText(
                                      _textController.text,
                                      style: _getTextStyle(),
                                      textAlign: _textAlign,
                                      minFontSize:
                                          8.0, // Prevent it from shrinking too much due to padding
                                      wrapWords: true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),

        // --- NON-SCREENSHOTTED OUTSIDE TOOLBAR ---
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kInkSurface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 12,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Tools
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note),
                        color: kGold,
                        onPressed: _showEditTextDialog,
                      ),
                      IconButton(
                        icon: const Icon(Icons.palette),
                        color: _textColor,
                        onPressed: _showColorPicker,
                      ),
                      IconButton(
                        icon: RotatedBox(
                          quarterTurns: 1,
                          child: const Icon(Icons.rotate_right),
                        ),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _rotationAngle += pi / 12;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          _showBackground ? Icons.layers : Icons.layers_clear,
                        ),
                        color: Colors.white,
                        onPressed: () =>
                            setState(() => _showBackground = !_showBackground),
                      ),
                      IconButton(
                        icon: Icon(_getAlignmentIcon()),
                        color: kRose,
                        onPressed: _toggleAlignment,
                      ),
                      IconButton(
                        icon: Icon(
                          _showStyleControls ? Icons.tune : Icons.style,
                        ),
                        color: _showStyleControls ? kGold : Colors.white,
                        onPressed: () => setState(
                          () => _showStyleControls = !_showStyleControls,
                        ),
                      ),
                      IconButton(
                        icon: RotatedBox(
                          quarterTurns: 1,
                          child: const Icon(Icons.compress),
                        ),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (_boxWidthRatio > 0.4) _boxWidthRatio -= 0.1;
                          });
                        },
                      ),
                      IconButton(
                        icon: RotatedBox(
                          quarterTurns: 1,
                          child: const Icon(Icons.expand),
                        ),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            if (_boxWidthRatio < 1.0) _boxWidthRatio += 0.1;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                if (_showStyleControls) ...[
                  const Divider(color: Colors.white12, height: 12),
                  // Opacity Slider
                  Row(
                    children: [
                      const Icon(Icons.opacity, color: kGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _bgOpacity,
                          min: 0.0,
                          max: 1.0,
                          activeColor: kGold,
                          onChanged: (val) => setState(() => _bgOpacity = val),
                        ),
                      ),
                      Text(
                        '${(_bgOpacity * 100).toInt()}%',
                        style: kMonoStyle(10, color: kGold),
                      ),
                    ],
                  ),
                  // Padding Slider
                  Row(
                    children: [
                      const Icon(Icons.space_bar, color: kRose, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Slider(
                          value: _padding,
                          min: 0.0,
                          max: 48.0,
                          activeColor: kRose,
                          onChanged: (val) => setState(() => _padding = val),
                        ),
                      ),
                      Text(
                        '${_padding.toInt()}px',
                        style: kMonoStyle(10, color: kRose),
                      ),
                    ],
                  ),
                ],

                const Divider(color: Colors.white24, height: 16),

                // Font Size Slider
                Row(
                  children: [
                    const Icon(Icons.text_increase, color: kGold, size: 16),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                        ),
                        child: Slider(
                          value: _fontScale,
                          min: 0.5,
                          max: 3.0,
                          activeColor: kGold,
                          inactiveColor: kMuted.withValues(alpha: 0.3),
                          onChanged: (val) => setState(() => _fontScale = val),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Font Family Row
                SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _fontOptions.length,
                    itemBuilder: (context, index) {
                      final font = _fontOptions[index];
                      final isSelected = font == _currentFont;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ActionChip(
                          label: Text(
                            font,
                            style: GoogleFonts.getFont(font).copyWith(
                              fontSize: 12,
                              color: isSelected ? Colors.black : Colors.white,
                            ),
                          ),
                          backgroundColor: isSelected
                              ? kGold
                              : Colors.transparent,
                          side: BorderSide(
                            color: isSelected ? kGold : Colors.white24,
                          ),
                          onPressed: () => setState(() => _currentFont = font),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
