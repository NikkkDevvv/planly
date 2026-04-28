import 'package:flutter/material.dart';

class AppColors {
  // Warna Utama (Input User)
  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF64748B);
  static const Color tertiary = Color(0xFFF1F5F9);
  static const Color neutral = Color(0xFF1E293B);

  // Variabel Pendukung (Sync dengan main_layout & home_screens)
  static const Color surface = Color(0xFFF8FAFC); // Latar belakang aplikasi
  static const Color onSurface = Color(0xFF1E293B); // Teks utama (neutral)
  static const Color onSurfaceVariant = Color(
    0xFF64748B,
  ); // Teks sekunder (secondary)

  static const Color surfaceContainerLowest = Color(
    0xFFFFFFFF,
  ); // Background kartu putih
  static const Color surfaceContainerLow = Color(
    0xFFF1F5F9,
  ); // Background break/item (tertiary)
  static const Color surfaceContainerHigh = Color(
    0xFFE2E8F0,
  ); // Background bento card
  static const Color surfaceBright = Color(
    0xFFF8FAFC,
  ); // Background input field

  static const Color primaryContainer = Color(
    0xFFE0E7FF,
  ); // Background indigo muda
  static const Color secondaryContainer = Color(
    0xFFF1F5F9,
  ); // Background abu-abu muda

  static const Color outline = Color(
    0xFF94A3B8,
  ); // Warna placeholder/ikon redup
  static const Color outlineVariant = Color(
    0xFFE2E8F0,
  ); // Warna border/garis pemisah

  // Warna Teks di atas warna utama
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixed = Color(0xFF1E293B);
  static const Color onPrimaryFixedVariant = Color(0xFF4F46E5);
}
