# 🌟 Planly Academic

Planly Academic adalah aplikasi Flutter modern yang dirancang khusus untuk mahasiswa dalam mengelola aktivitas akademik sehari-hari. Aplikasi ini mengusung antarmuka premium berbasis **Bento Grid** dengan arsitektur modular yang rapi, berkinerja tinggi, dan ramah skalabilitas.

---

## ✨ Fitur Utama

*   📅 **Halaman Hari Ini (Home)**: Linimasa jadwal kelas perkuliahan harian *real-time*, status kelas yang dipindahkan (*rescheduled*), serta pintasan Pomodoro belajar.
*   🗓️ **Kalender Jadwal (Schedules)**: Kalender akademik interaktif dengan navigasi strip mingguan (*weekly strip*) dan tampilan kalender bulanan (*monthly grid*).
*   📝 **Daftar Tugas Kuliah (Tasks)**: Manajemen tugas teratur dengan filter status, kategori tingkat prioritas, dan tanggal tenggat waktu (*deadline*).
*   🎓 **Mata Kuliah (Courses)**: Ringkasan detail mata kuliah lengkap beserta jumlah SKS, ruang kelas, dan dosen pengampu.
*   ✍️ **Catatan Belajar (Notes)**: Editor catatan kaya fitur yang mendukung rendering rumus Matematika / persamaan LaTeX.
*   📢 **Kegiatan Kampus (Campus Events)**: Kalender informasi kegiatan internal dan eksternal kampus lengkap dengan kategori acara.
*   ⏱️ **Ruang Belajar (Workspace)**: Sesi fokus belajar menggunakan *Pomodoro Timer* yang terintegrasi dengan pemutar musik latar penenang (*ambient sounds*).
*   📍 **Absensi Kehadiran (Attendance)**: Sistem presensi kehadiran mandiri mahasiswa menggunakan deteksi radius lokasi GPS dan foto unggahan secara langsung.
*   👤 **Profil Saya (User Profile)**: Pengaturan biodata diri (NIM, Semester, Program Studi), target IPK vs IPK saat ini, target jam belajar harian, serta penggantian avatar profil.

---

## 🛠️ Tech Stack & Pustaka Pendukung

*   **Framework**: Flutter SDK (Dart 3.x)
*   **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Pola BLoC arsitektur modular)
*   **Koneksi API**: [dio](https://pub.dev/packages/dio) & [http](https://pub.dev/packages/http) terintegrasi dengan API backend Laravel.
*   **Animasi Premium**:
    *   [flutter_animate](https://pub.dev/packages/flutter_animate): Efek transisi halus (*fade, slide, scale, shimmer*) pada elemen daftar dan kartu bento.
    *   [lottie](https://pub.dev/packages/lottie): Integrasi ilustrasi animasi interaktif JSON berdefinisi tinggi untuk mempercantik layar pemuatan data (*empty state & splash screen*).
*   **Matematika / LaTeX**: [flutter_math_fork](https://pub.dev/packages/flutter_math_fork) untuk rendering persamaan matematika berkecepatan tinggi.
*   **Geolokasi**: [geolocator](https://pub.dev/packages/geolocator) untuk verifikasi titik GPS mahasiswa saat presensi.
*   **Desain & Tipografi**: [google_fonts](https://pub.dev/packages/google_fonts) (Inter & Outfit) & [toastification](https://pub.dev/packages/toastification) (umpan balik notifikasi/toast melayang).

---

## 📂 Struktur Proyek (Modular Architecture)

Aplikasi ini menerapkan standardisasi struktur folder berbasis fitur (**Feature-Driven Directory Structure**) untuk mempermudah kolaborasi pengembang dan perluasan fitur di masa depan:

```
lib/
├── core/                  # Utilitas global, konstanta, tema warna & widget reusable
│   ├── constants/         # Konstanta teks global & konstanta endpoint API
│   ├── theme/             # Definisi skema warna aplikasi (AppColors)
│   ├── utils/             # Helper fungsi (date_utils, schedule_helper, validators)
│   └── widgets/           # Widget global (BentoStatCard, LoadingIndicator)
├── data/                  # Lapisan data terpusat (models, services, storage)
│   └── models/            # Model data bersama (UserModel, EffectiveCourse)
└── features/              # Modul fitur mandiri (terdekomposisi & terstandardisasi)
    ├── auth/              # Layar masuk (Login) & pendaftaran (Register)
    ├── home/              # Halaman linimasa hari ini & statistik bento
    ├── schedules/         # Layar kalender mingguan & kalender bulanan
    ├── tasks/             # Manajemen daftar tugas kuliah & kartu tugas
    ├── courses/           # Layar informasi mata kuliah & kartu dosen
    ├── notes/             # Layar pembuat catatan & render LaTeX
    ├── events/            # Layar daftar & kategori kegiatan kampus
    ├── workspace/         # Ruang belajar fokus Pomodoro & ambient sounds
    ├── attendance/        # Form check-in presensi GPS & riwayat absensi
    └── profile/           # Layar detail biodata profil, target IPK, & menu opsi
```

---

## 🚀 Panduan Memulai (Instalasi)

### Prasyarat
*   Flutter SDK terinstal (versi `>=3.11.1` atau lebih baru).
*   Dart SDK terinstal.
*   Perangkat emulator / fisik (Android / iOS).

### Langkah-langkah Menjalankan Proyek:

1.  **Clone Repositori**:
    ```bash
    git clone https://github.com/NikkkDevvv/planly.git
    cd planly
    ```

2.  **Ambil Dependensi**:
    ```bash
    flutter pub get
    ```

3.  **Siapkan Variabel Lingkungan**:
    Buat berkas `.env` di root folder proyek dan konfigurasi URL API backend Anda:
    ```env
    API_URL=http://<IP-BACKEND-ANDA>:<PORT>/api
    ```

4.  **Jalankan Aplikasi**:
    ```bash
    flutter run
    ```
