import 'package:flutter/material.dart';

class AppColors {
  // ── Surfaces ─────────────────────────────────────────────────────────────
  static const Color background       = Color(0xFFFAFAF7); // warm ivory
  static const Color surface          = Color(0xFFFFFFFF); // pure white cards
  static const Color surfaceSecondary = Color(0xFFF5F4F0); // subtle warm fill
  static const Color surfaceLight     = Color(0xFFF5F4F0); // alias for compat

  // ── Borders ──────────────────────────────────────────────────────────────
  static const Color border       = Color(0xFFE8E5DE); // warm hairline
  static const Color borderStrong = Color(0xFFD1CCC3); // emphasized dividers

  // ── Accent — institutional teal ──────────────────────────────────────────
  static const Color accent      = Color(0xFF1A5276);
  static const Color accentLight = Color(0xFF2980B9);
  static const Color accentDark  = Color(0xFF14415E);
  static const Color accentSubtle = Color(0xFFEBF5FB); // tinted background
  static const Color gold        = Color(0xFF1A5276); // alias kept for compat

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1C1C1A); // warm near-black
  static const Color textSecondary = Color(0xFF5C5C57); // body secondary
  static const Color textMuted     = Color(0xFF9C9A93); // captions

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF1E8449); // forest green
  static const Color error   = Color(0xFFC0392B); // muted brick
  static const Color warning = Color(0xFFD4A017); // warm amber

  // ── Chat bubbles ─────────────────────────────────────────────────────────
  static const Color bubbleUser      = Color(0xFFEBF5FB); // teal wash
  static const Color bubbleAssistant = Color(0xFFF9F9F6); // barely warm
}
