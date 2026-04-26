import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../app_theme.dart';
import '../services/poem_api_service.dart';
import '../widgets/editable_draggable_text.dart';
import '../widgets/poem_settings_sheet.dart';

class PoemEditorScreen extends StatefulWidget {
  final File imageFile;
  final int poemLength;
  final String userTheme;

  const PoemEditorScreen({
    super.key,
    required this.imageFile,
    required this.poemLength,
    required this.userTheme,
  });

  @override
  State<PoemEditorScreen> createState() => _PoemEditorScreenState();
}

class _PoemEditorScreenState extends State<PoemEditorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();

  bool _isGenerating = false;
  bool _isSaving = false;
  bool _hasStartedGeneration =
      false; // Prevents editor from showing before first generation

  String _generatedPoem = "";
  List<String> _poemHistory = [];
  int _historyIndex = -1;
  double _imageAspectRatio = 1.0;

  late int _currentLength;
  late String _currentTheme;
  String? _currentRoughDraft;

  @override
  void initState() {
    super.initState();
    _currentLength = widget.poemLength;
    _currentTheme = widget.userTheme;
    _preloadImageAspect();

    // Automatically show settings on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegenerateSettings();
    });
  }

  Future<void> _preloadImageAspect() async {
    final bytes = await widget.imageFile.readAsBytes();
    final decodedImage = await decodeImageFromList(bytes);
    if (!mounted) return;
    setState(() {
      _imageAspectRatio = decodedImage.width / decodedImage.height;
    });
  }

  void _showRegenerateSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: _hasStartedGeneration, // Force interaction initially
      enableDrag: _hasStartedGeneration,
      backgroundColor: const Color(0xFF0A0A0A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        // If it's forced initially, wrap it in a PopScope to pop the screen if they cancel hardware back
        return PopScope(
          canPop: _hasStartedGeneration,
          onPopInvokedWithResult: (didPop, _) {
            if (!_hasStartedGeneration && !didPop) {
              Navigator.of(context).pop(); // kill modal
              Navigator.of(context).pop(); // kill screen entirely
            }
          },
          child: PoemSettingsSheet(
            initialLength: _currentLength,
            initialTheme: _currentTheme,
            onApply: (length, theme, roughDraft) {
              setState(() {
                _currentLength = length;
                _currentTheme = theme;
                _currentRoughDraft = roughDraft;
              });
              _startPoemGeneration();
            },
          ),
        );
      },
    );
  }

  Future<void> _startPoemGeneration() async {
    setState(() {
      _isGenerating = true;
      _hasStartedGeneration = true;
    });

    try {
      final response = await PoemApiService.generatePoem(
        widget.imageFile.path,
        _currentLength,
        _currentTheme,
        roughDraft: _currentRoughDraft,
      );

      if (!mounted) return;
      setState(() {
        _commitNewText(response.poem.trim());
        _isGenerating = false;
      });
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString();
      if (errorStr.contains('USER_LIMIT_REACHED')) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You have reached your generation limit for now. Please wait a minute.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (errorStr.contains('NETWORK_ERROR')) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Connection failed. Please check your internet and try again.',
            ),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 4),
          ),
        );
      } else if (errorStr.contains('PROVIDER_BUSY')) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'The AI poet is currently busy. Please try tapping regenerate in a few seconds.',
            ),
            backgroundColor: Colors.amber,
            duration: Duration(seconds: 4),
          ),
        );
      } else {
        setState(() {
          _commitNewText("Error generating:\n$e");
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _saveToGallery() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final imageBytes = await _screenshotController.capture();
      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/neural_poet_${DateTime.now().millisecondsSinceEpoch}.png';

        final file = File(filePath);
        await file.writeAsBytes(imageBytes);

        final result = await GallerySaver.saveImage(filePath);

        if (!mounted) return;
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Saved to Gallery successfully!',
                style: kBodyStyle(13, color: kInk),
              ),
              backgroundColor: kGold,
            ),
          );
        } else {
          throw Exception('Failed to save via platform channel');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save to Gallery: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // To receive manual text edits
  void _onTextOverride(String text) {
    setState(() {
      _commitNewText(text);
    });
  }

  void _commitNewText(String text) {
    if (_historyIndex < _poemHistory.length - 1) {
      _poemHistory = _poemHistory.sublist(0, _historyIndex + 1);
    }
    _poemHistory.add(text);
    _historyIndex = _poemHistory.length - 1;
    _generatedPoem = _poemHistory[_historyIndex];
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _generatedPoem = _poemHistory[_historyIndex];
      });
    }
  }

  void _redo() {
    if (_historyIndex < _poemHistory.length - 1) {
      setState(() {
        _historyIndex++;
        _generatedPoem = _poemHistory[_historyIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: kInk,
        title: const SizedBox.shrink(),
        // leading: const BackButton(),
        actions: [
          if (_hasStartedGeneration && !_isGenerating) ...[
            IconButton(
              icon: const Icon(Icons.undo),
              color: _historyIndex > 0 ? Colors.white : Colors.white38,
              tooltip: 'Undo',
              onPressed: _historyIndex > 0 ? _undo : null,
            ),
            IconButton(
              icon: const Icon(Icons.redo),
              color: _historyIndex < _poemHistory.length - 1
                  ? Colors.white
                  : Colors.white38,
              tooltip: 'Redo',
              onPressed: _historyIndex < _poemHistory.length - 1 ? _redo : null,
            ),
            // Shiny Bordered Regenerate Button
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: kRose.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: _showRegenerateSettings,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Regenerate',
                          style: kMonoStyle(
                            11,
                            color: kParchment,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.auto_awesome, color: kRose, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: kGold,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.download, color: kGold),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    tooltip: 'Save to Gallery',
                    onPressed: _saveToGallery,
                  ),
          ],
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Pixel/letter background visible while generating / waiting
          if (!_hasStartedGeneration || _isGenerating) ...[
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Image.file(widget.imageFile, fit: BoxFit.cover),
              ),
            ),
            Container(color: kInk.withValues(alpha: 0.55)),
            if (_isGenerating)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.inkDrop(color: kGold, size: 60),
                    const SizedBox(height: 28),
                    DefaultTextStyle(
                      style: kTitleStyle(18).copyWith(color: kParchment),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Reading the light…',
                            speed: const Duration(milliseconds: 90),
                          ),
                          TypewriterAnimatedText(
                            'Feeling the colours…',
                            speed: const Duration(milliseconds: 90),
                          ),
                          TypewriterAnimatedText(
                            'Writing the verse…',
                            speed: const Duration(milliseconds: 90),
                          ),
                          TypewriterAnimatedText(
                            'Almost ready…',
                            speed: const Duration(milliseconds: 90),
                          ),
                        ],
                        repeatForever: true,
                      ),
                    ),
                  ],
                ),
              ),
          ] else
            SafeArea(
              child: EditableDraggableText(
                initialText: _generatedPoem,
                screenshotController: _screenshotController,
                imageAspectRatio: _imageAspectRatio,
                backgroundLayer: Image.file(
                  widget.imageFile,
                  fit: BoxFit.cover,
                ),
                onTextChanged: _onTextOverride,
              ),
            ),
        ],
      ),
    );
  }
}
