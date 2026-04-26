import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_theme.dart';
import '../services/poem_api_service.dart';
import '../widgets/pixel_letter_background.dart';
import '../widgets/poem_settings_sheet.dart';
import 'poem_editor_screen.dart';

class PhotoPoemScreen extends StatefulWidget {
  const PhotoPoemScreen({super.key});

  @override
  State<PhotoPoemScreen> createState() => _PhotoPoemScreenState();
}

class _PhotoPoemScreenState extends State<PhotoPoemScreen>
    with SingleTickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();

  int _poemLength = 30;
  String _userTheme = "Mystical";

  late AnimationController _fadeController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _poemLength = prefs.getInt('poemLength') ?? 30;
      _userTheme = prefs.getString('userTheme') ?? "Mystery";
    });
  }

  Future<void> _saveSettings(int length, String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('poemLength', length);
    await prefs.setString('userTheme', theme);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PoemEditorScreen(
              imageFile: File(pickedFile.path),
              poemLength: _poemLength,
              userTheme: _userTheme,
            ),
          ),
        );
        // Refresh UI to show updated remaining requests
        setState(() {});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kInk,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return PoemSettingsSheet(
          initialLength: _poemLength,
          initialTheme: _userTheme,
          buttonLabel: 'SAVE SETTINGS',
          showRoughDraftSection: false,
          onApply: (length, theme, roughDraft) {
            setState(() {
              _poemLength = length;
              _userTheme = theme;
            });
            _saveSettings(length, theme);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kInk,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const PixelLetterBackground(),
          const VignetteOverlay(baseColor: kInk),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                children: [
                  // ── Top bar (title + tagline) ────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Photo Poetry App',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cormorantGaramond(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: kParchment,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Translate pixels to poetry...',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            color: kParchment.withOpacity(0.88),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.6,
                            shadows: [
                              Shadow(
                                color: kInk.withOpacity(0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ── Middle section (commented out for now) ─────
                  // Text(
                  //   'Translate pixels to poetry...',
                  //   style: GoogleFonts.lora(
                  //     fontSize: 15,
                  //     color: kParchment.withOpacity(0.88),
                  //     fontStyle: FontStyle.italic,
                  //     letterSpacing: 0.8,
                  //     shadows: [
                  //       Shadow(
                  //         color: kInk.withOpacity(0.8),
                  //         blurRadius: 8,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  const Spacer(),

                  // --- Generations Left Indicator (Centered above buttons) ---
                  Builder(
                    builder: (context) {
                      final remaining = PoemApiService.remainingRequests ?? 5;
                      final resetAt = PoemApiService.resetAt;

                      String resetText = "LIMIT: 5 / 15 MINS";
                      if (resetAt != null) {
                        final now =
                            DateTime.now().millisecondsSinceEpoch / 1000;
                        final diff = resetAt - now;
                        if (diff > 0) {
                          final mins = (diff / 60).ceil();
                          resetText = "RESETS IN $mins MINS";
                        }
                      }

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: kGold.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '$remaining GENERATIONS LEFT',
                              style: GoogleFonts.spaceGrotesk(
                                color: kGold,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            resetText,
                            style: GoogleFonts.spaceGrotesk(
                              color: kGold.withOpacity(0.5),
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Action Buttons ─────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ActionTile(
                                icon: Icons.camera_alt_outlined,
                                label: 'CAMERA',
                                color: const Color(0xFF7EB5A6), // sage teal
                                onTap: () => _pickImage(ImageSource.camera),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _ActionTile(
                                icon: Icons.photo_library_outlined,
                                label: 'GALLERY',
                                color: const Color(
                                  0xFF9D85BE,
                                ), // muted lavender
                                onTap: () => _pickImage(ImageSource.gallery),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Settings button spanning both columns
                        GestureDetector(
                          onTap: _showSettings,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: kGold.withOpacity(0.06),
                              border: Border.all(color: kGold.withOpacity(0.4)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.tune, color: kGold, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'POEM SETTINGS',
                                  style: GoogleFonts.spaceGrotesk(
                                    color: kGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 52),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _press;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _press, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press.forward(),
      onTapUp: (_) {
        _press.reverse();
        widget.onTap();
      },
      onTapCancel: () => _press.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.08),
            border: Border.all(color: widget.color, width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.2),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: widget.color, size: 36),
              const SizedBox(height: 10),
              Text(
                widget.label,
                style: GoogleFonts.spaceGrotesk(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
