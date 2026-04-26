import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';

class PoemSettingsSheet extends StatefulWidget {
  final int initialLength;
  final String initialTheme;
  final String? buttonLabel;
  final bool showRoughDraftSection;
  final Function(int length, String theme, String? roughDraft) onApply;

  const PoemSettingsSheet({
    super.key,
    required this.initialLength,
    required this.initialTheme,
    this.buttonLabel,
    this.showRoughDraftSection = true,
    required this.onApply,
  });

  @override
  State<PoemSettingsSheet> createState() => _PoemSettingsSheetState();
}

class _PoemSettingsSheetState extends State<PoemSettingsSheet> {
  late double _currentLength;
  late TextEditingController _themeController;
  final TextEditingController _roughDraftController = TextEditingController();
  bool _showRoughDraft = false;

  final List<String> _suggestedThemes = [
    "Love",
    "Mystery",
    "Nature",
    "Hope",
    "Solitude",
    "Joy",
    "Longing",
  ];

  @override
  void initState() {
    super.initState();
    _currentLength = widget.initialLength.toDouble();
    _themeController = TextEditingController(text: widget.initialTheme);
  }

  @override
  void dispose() {
    _themeController.dispose();
    _roughDraftController.dispose();
    super.dispose();
  }

  void _addThemePreset(String preset) {
    if (_themeController.text.isEmpty) {
      _themeController.text = preset;
    } else {
      _themeController.text = '${_themeController.text}, $preset';
    }
    setState(() {});
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.lora(color: kMuted, fontSize: 13),
    filled: true,
    fillColor: kInkSurface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kGold),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kMuted.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kGold, width: 1.8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        color: kInk,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 28,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kMuted.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Row(
                  children: [
                    const Icon(Icons.auto_stories, color: kGold, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      'Poem Settings',
                      style: GoogleFonts.cormorantGaramond(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: kGold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Word count
                Text(
                  'Word Count: ${_currentLength.toInt()}',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: kParchment.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kGold,
                    inactiveTrackColor: kMuted.withValues(alpha: 0.3),
                    thumbColor: kParchment,
                    overlayColor: kGold.withValues(alpha: 0.15),
                  ),
                  child: Slider(
                    value: _currentLength,
                    min: 10,
                    max: 100,
                    // divisions: 9,
                    onChanged: (v) => setState(() => _currentLength = v),
                  ),
                ),
                const SizedBox(height: 20),

                // Theme field
                Text(
                  'Poetic Theme',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: kParchment.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _themeController,
                  maxLength: 30,
                  style: GoogleFonts.lora(color: kParchment, fontSize: 14),
                  decoration: _fieldDecoration("e.g. Melancholy, Nature, Love…")
                      .copyWith(
                        counterStyle: GoogleFonts.spaceGrotesk(
                          color: kMuted,
                          fontSize: 11,
                        ),
                      ),
                ),
                const SizedBox(height: 14),

                // Theme chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _suggestedThemes.map((theme) {
                    return ActionChip(
                      label: Text(theme),
                      backgroundColor: kInkSurface,
                      labelStyle: GoogleFonts.lora(
                        color: kParchment,
                        fontSize: 12,
                      ),
                      side: BorderSide(color: kRose.withValues(alpha: 0.45)),
                      onPressed: () => _addThemePreset(theme),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // ── Rough Draft Toggle ──────────────────────────
                if (widget.showRoughDraftSection) ...[
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showRoughDraft = !_showRoughDraft),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _showRoughDraft
                            ? kGold.withValues(alpha: 0.10)
                            : kInkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showRoughDraft
                              ? kGold.withValues(alpha: 0.6)
                              : kMuted.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.draw_outlined,
                            color: _showRoughDraft ? kGold : kMuted,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Refine my own draft',
                                  style: GoogleFonts.lora(
                                    fontSize: 14,
                                    color: _showRoughDraft ? kGold : kParchment,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'AI will capture the soul of the image and weave it into your words',
                                  style: GoogleFonts.lora(
                                    fontSize: 12,
                                    color: kMuted,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _showRoughDraft
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: kMuted,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Animated rough draft text field
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 250),
                    crossFadeState: _showRoughDraft
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          'Your Rough Draft',
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            color: kParchment.withValues(alpha: 0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Builder(
                          builder: (context) {
                            final charCount = _roughDraftController.text.length;
                            final over = charCount > 250;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _roughDraftController,
                                  maxLines: 7,
                                  minLines: 4,
                                  maxLength: 250,
                                  style: GoogleFonts.lora(
                                    color: kParchment,
                                    fontSize: 14,
                                    height: 1.6,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Write your rough poem here…\nThe AI will weave the image's soul into your words.",
                                    hintStyle: GoogleFonts.lora(
                                      color: kMuted,
                                      fontSize: 13,
                                    ),
                                    filled: true,
                                    fillColor: kInkSurface,
                                    counterStyle: GoogleFonts.spaceGrotesk(
                                      fontSize: 11,
                                      color: over ? kRose : kMuted,
                                      fontWeight: over
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: kGold,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: kMuted.withValues(alpha: 0.4),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: over ? kRose : kGold,
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                // Generate button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGold,
                      foregroundColor: kInk,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      final roughDraft = _roughDraftController.text.trim();
                      if (roughDraft.length > 250) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Your draft exceeds 250 characters. Please shorten it.',
                              style: kBodyStyle(13, color: kInk),
                            ),
                            backgroundColor: kRose,
                          ),
                        );
                        return;
                      }
                      if (_themeController.text.length > 30) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Theme exceeds 30 characters. Please shorten it.',
                              style: kBodyStyle(13, color: kInk),
                            ),
                            backgroundColor: kRose,
                          ),
                        );
                        return;
                      }
                      widget.onApply(
                        _currentLength.toInt(),
                        _themeController.text,
                        roughDraft.isEmpty ? null : roughDraft,
                      );
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.buttonLabel ??
                          (_showRoughDraft &&
                                  _roughDraftController.text.trim().isNotEmpty
                              ? 'REFINE MY POEM'
                              : 'GENERATE POEM'),
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.4,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
