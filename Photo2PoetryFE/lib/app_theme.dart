/// App-wide design tokens for the Poetic theme.
/// Import this wherever colours or fonts are needed.
library app_theme;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour Palette ──────────────────────────────────────────────────────────
const kInk = Color(0xFF0E0C14); // deep midnight-ink background
const kParchment = Color(0xFFF5E6C8); // warm cream / parchment
const kGold = Color(0xFFD4A843); // aged-gold accent (primary)
const kRose = Color(0xFFC4647A); // dusty rose accent (secondary)
const kInkSurface = Color(0xFF1C1826); // slightly lighter surface
const kMuted = Color(0xFF7A6E83); // muted lavender-grey

// ── Typography ──────────────────────────────────────────────────────────────
TextStyle kTitleStyle(double size) => GoogleFonts.cormorantGaramond(
  fontSize: size,
  fontWeight: FontWeight.w700,
  color: kParchment,
  letterSpacing: 1.5,
);

TextStyle kBodyStyle(double size, {Color color = kParchment}) =>
    GoogleFonts.lora(fontSize: size, color: color);

TextStyle kMonoStyle(double size, {Color color = kGold}) =>
    GoogleFonts.spaceGrotesk(fontSize: size, color: color, letterSpacing: 1.2);

// ── Material ThemeData ───────────────────────────────────────────────────────
ThemeData poeticTheme(BuildContext context) => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kInk,
  primaryColor: kGold,
  colorScheme: const ColorScheme.dark(
    primary: kGold,
    secondary: kRose,
    surface: kInkSurface,
  ),
  textTheme: GoogleFonts.loraTextTheme(
    Theme.of(
      context,
    ).textTheme.apply(bodyColor: kParchment, displayColor: kParchment),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: kInk,
    elevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: kGold),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: kGold,
    inactiveTrackColor: kMuted.withValues(alpha: 0.3),
    thumbColor: kParchment,
    overlayColor: kGold.withValues(alpha: 0.15),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kGold,
      foregroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kInkSurface,
    labelStyle: GoogleFonts.lora(color: kParchment, fontSize: 13),
    side: BorderSide(color: kRose.withValues(alpha: 0.5)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kInkSurface,
    hintStyle: TextStyle(color: kMuted),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kRose.withValues(alpha: 0.4)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kMuted.withValues(alpha: 0.4)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kGold, width: 1.8),
    ),
  ),
);
