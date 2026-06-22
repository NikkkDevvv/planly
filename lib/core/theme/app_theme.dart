import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textLightPrimary,
        outlineVariant: AppColors.outlineLight,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        // Display Large: Outfit, size 30px, Bold (Judul Halaman Utama)
        displayLarge: GoogleFonts.outfit(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppColors.textLightPrimary,
        ),
        // Title Large: Outfit, size 20px, SemiBold (Judul Kartu, Header Section)
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textLightPrimary,
        ),
        // Body Large: Inter, size 16px, Regular/Medium (Teks Utama, Konten Catatan)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textLightPrimary,
        ),
        // Body Medium: Inter, size 14px, Regular (Deskripsi Tugas, Teks Sub-Header)
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textLightSecondary,
        ),
        // Label Small: Inter, size 12px, SemiBold/Bold (Chip Badge, Caption, Status Waktu)
        labelSmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textLightSecondary,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textLightPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
    );
  }
}
