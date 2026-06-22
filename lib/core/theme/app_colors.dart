import 'package:flutter/material.dart';

class AppColors {
  // === Warna Inti (Core Colors) ===
  static const Color primary = Color(0xFF4F46E5);          // Indigo — warna tombol utama, aksen aktif
  static const Color primaryContainer = Color(0xFFE0E7FF); // Background chip/badge primary
  static const Color secondary = Color(0xFF64748B);        // Teks sekunder, ikon redup
  static const Color secondaryContainer = Color(0xFFF1F5F9); // Background item abu-abu terang

  // === Warna Latar (Light Mode Surface) ===
  static const Color bgLight = Color(0xFFF8FAFC);          // Latar belakang halaman utama
  static const Color surfaceLight = Color(0xFFFFFFFF);     // Kartu utama, dialog modal
  static const Color surfaceLowLight = Color(0xFFF1F5F9);  // Item tersier
  static const Color outlineLight = Color(0xFFE2E8F0);     // Border kartu, pembatas tipis

  // === Warna Latar (Dark Mode Surface) ===
  static const Color bgDark = Color(0xFF0F172A);           // Latar belakang halaman utama (Slate 900)
  static const Color surfaceDark = Color(0xFF1E293B);      // Kartu utama, dialog modal (Slate 800)
  static const Color surfaceLowDark = Color(0xFF334155);   // Item tersier (Slate 700)
  static const Color outlineDark = Color(0xFF1E293B);      // Border kartu (Slate 800)

  // === Teks ===
  static const Color textLightPrimary = Color(0xFF1E293B);  // Teks utama light mode
  static const Color textLightSecondary = Color(0xFF64748B);// Teks pembantu light mode
  static const Color textDarkPrimary = Color(0xFFF1F5F9);   // Teks utama dark mode
  static const Color textDarkSecondary = Color(0xFF94A3B8);  // Teks pembantu dark mode

  // === Warna Semantik (Semantic Colors) ===
  static const Color error = Color(0xFFBA1A1A);            // Merah — error, overdue, tombol hapus
  static const Color errorContainer = Color(0xFFFFDADC);   // Background badge error
  static const Color success = Color(0xFF16A34A);          // Hijau — presensi hadir, tugas selesai
  static const Color successContainer = Color(0xFFDCFCE7);  // Background badge sukses
  static const Color warning = Color(0xFFD97706);          // Jingga — kelas dipindahkan, belum presensi
  static const Color warningContainer = Color(0xFFFEF3C7);  // Background badge warning

  // === Compatibility Aliases (Light Mode Defaults) ===
  static const Color surface = bgLight;
  static const Color onSurface = textLightPrimary;
  static const Color onSurfaceVariant = textLightSecondary;
  static const Color outline = secondary;
  static const Color outlineVariant = outlineLight;
  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerLow = surfaceLowLight;
  static const Color surfaceContainerHigh = Color(0xFFE2E8F0);
  static const Color surfaceBright = bgLight;
  static const Color onPrimary = Colors.white;
  static const Color onPrimaryFixed = textLightPrimary;
  static const Color onPrimaryFixedVariant = primary;
}
