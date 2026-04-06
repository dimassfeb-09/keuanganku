# Keuanganku 💰

**Keuanganku** adalah aplikasi manajemen keuangan pribadi yang modern, elegan, dan intuitif. Dirancang untuk membantu Anda melacak setiap pengeluaran dan pemasukan dengan mudah, mengelola berbagai dompet, serta memberikan wawasan mendalam tentang kesehatan finansial Anda melalui analisis visual yang interaktif.

---

## ✨ Fitur Utama

-   **Multi-Wallet Management**: Kelola berbagai sumber dana (Tunai, Bank, E-Wallet) dengan personalisasi warna dan ikon yang elegan.
-   **Pencatatan Transaksi Cepat**: Antarmuka input nominal yang besar dan fokus untuk efisiensi tinggi.
-   **Manajemen Kategori**: Sesuaikan kategori pengeluaran dan pemasukan Anda sendiri dengan ribuan pilihan ikon.
-   **Anggaran Bulanan (Budgeting)**: Atur limit pengeluaran tiap kategori dan pantau progresnya secara real-time untuk mencegah pemborosan.
-   **Analisis Interaktif**: Diagram lingkaran (Pie Chart) yang interaktif untuk melihat distribusi pengeluaran Anda.
-   **Transaksi Rutin**: Fitur otomatisasi untuk mencatat transaksi yang berulang secara periodik (harian, mingguan, bulanan).
-   **Keamanan Data Lokal**: Seluruh data disimpan secara lokal di perangkat Anda menggunakan SQLite untuk privasi maksimal.
-   **Premium UI/UX**: Desain modern dengan animasi halus, gradien menawan, dan estetika yang premium.

---

## 🛠️ Teknologi & Arsitektur

Aplikasi ini dibangun menggunakan teknologi terkini di ekosistem Flutter:

-   **Framework**: [Flutter](https://flutter.dev) (SDK ^3.10.4)
-   **State Management**: [Flutter Riverpod](https://riverpod.dev) (Terstruktur dan reaktif)
-   **Database**: [SQLite](https://pub.dev/packages/sqflite) (Persistensi data offline)
-   **UI Components**: Custom Design System dengan [Google Fonts (Outfit)](https://fonts.google.com/specimen/Outfit)
-   **Architecture**: Feature-Based Directory Structure (Meningkatkan kemudahan maintenance dan skalabilitas)

---

## 🚀 Cara Menjalankan Project

### Prasyarat
-   Sudah menginstal [Flutter SDK](https://docs.flutter.dev/get-started/install).
-   Sudah menginstal Android Studio / VS Code dengan plugin Flutter/Dart.

### Langkah-langkah
1.  **Clone Repository**
    ```bash
    git clone <repository-url>
    cd keuanganku
    ```
2.  **Instalasi Dependencies**
    ```bash
    flutter pub get
    ```
3.  **Jalankan Aplikasi**
    ```bash
    # Pastikan emulator atau perangkat sudah terhubung
    flutter run
    ```

---

## 📦 Cara Build Aplikasi (Produksi)

Untuk menjaga stabilitas icon pada versi release, gunakan perintah berikut:

```bash
flutter build apk --release --no-tree-shake-icons
```

> **Catatan Penting**: Penggunaan flag `--no-tree-shake-icons` diperlukan karena aplikasi menggunakan pemilihan ikon dinamis (IconData tidak konstan) yang bisa menyebabkan ikon hilang jika fitur tree-shaking Flutter diaktifkan secara default pada build release.

---

## 🎨 Mengatur Icon Aplikasi

Saat ini aplikasi menggunakan ikon default Flutter. Untuk mengganti ikon aplikasi ke logo kustom Anda, disarankan menggunakan package `flutter_launcher_icons`:

1.  Tambahkan package di `pubspec.yaml` bagian `dev_dependencies`:
    ```yaml
    dev_dependencies:
      flutter_launcher_icons: "^0.13.1"
    ```
2.  Konfigurasi ikon:
    ```yaml
    flutter_launcher_icons:
      android: "launcher_icon"
      ios: true
      image_path: "assets/images/logo.png" # Ganti dengan path logo Anda
      min_sdk_android: 21
    ```
3.  Jalankan perintah generate:
    ```bash
    flutter pub get
    ```
    ```bash
    flutter pub run flutter_launcher_icons
    ```

---

## 📂 Struktur Direktori

Kodingan aplikasi diatur berdasarkan fitur (Feature-based) agar mudah dikelola:

```text
lib/
├── core/               # Tema, Utils, dan helper database global
├── data/               # Model data
└── presentation/
    ├── providers/      # Logika aplikasi (Riverpod)
    ├── screens/        # Folder fitur (Home, Insight, Budget, dll)
    │   └── <feature>/
    │       ├── widgets/ # Widget spesifik fitur
    │       └── <feature>_screen.dart
    └── widgets/        # Widget global/umum
```

---

---

## 🤝 Kontribusi

Aplikasi ini dikembangkan sebagai solusi cerdas untuk manajemen keuangan harian. Jika Anda menemukan bug atau ingin menambahkan fitur, jangan ragu untuk melakukan pull request!

**Repository Resmi**: [https://github.com/dimassfeb-09/keuanganku](https://github.com/dimassfeb-09/keuanganku)

**Dibuat oleh Dimas**
© 2026 keuanganku. All Rights Reserved.
