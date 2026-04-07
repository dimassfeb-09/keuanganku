# 🚀 Deployment Action Plan: Keuanganku

Plan ini adalah jalur eksekusi cepat tanpa basa-basi untuk merilis atau mengupdate aplikasi Keuanganku ke Google Play Store. Tinggal ikuti checklist dari atas ke bawah.

---

### 🚀 Quick Deploy (TL;DR)
*(Khusus environment yang sudah pernah setup signing)*
1. Naikin `version: X.Y.Z+N` di `pubspec.yaml`
2. Run `flutter clean && flutter pub get`
3. Run `flutter build appbundle --release --no-tree-shake-icons`
4. Upload `build/app/outputs/bundle/release/app-release.aab` ke Play Console.
5. Tulis notes & Publish!

---

### Phase 1: Preparation (Buka Editor)
- [ ] Buka `pubspec.yaml`
- [ ] Ubah versi aplikasi. Wajib menaikkan `versionCode` (angka setelah `+`). Contoh: `1.0.1+2` menjadi `1.0.2+3`.
- [ ] Buka folder API/Config, pastikan `baseURL` dan proxy/environment mengarah murni ke **Production**.
- [ ] Cek file `android/key.properties`, pastikan file ada di tempatnya.
- [ ] Validasi *branch git*, pastikan kode yang akan dirilis berada pada *branch* stabil (misal: `main` atau `release`).

### Phase 2: Build App Bundle
- [ ] Buka terminal di root direktori project, jalankan pembersihan cache:
  ```bash
  flutter clean
  flutter pub get
  ```
- [ ] Jalankan command kompilasi ini (wajib memakai `--no-tree-shake-icons` agar dynamic icons tidak meledak di rilis akhir):
  ```bash
  flutter build appbundle --release --no-tree-shake-icons
  ```
  * **Expected Output**: Di akhir proses, terminal mengeluarkan teks hijau sukses `✓ Built build/app/outputs/bundle/release/app-release.aab`.

### Phase 3: Release (Play Console)
- [ ] Login ke [Google Play Console](https://play.google.com/console).
- [ ] Pilih Dashboard **Keuanganku**.
- [ ] Arahkan ke **Testing > Internal Testing** (untuk uji beta) atau **Production** (untuk go-live dunia).
- [ ] Tekan kanan atas: **Create new release / Buat rilis baru**.
- [ ] Upload *App Bundle* dari path lokal komputer Anda: `build/app/outputs/bundle/release/app-release.aab`
- [ ] Tulis *Release Notes* (Contoh: "Peningkatan fitur dompet dan fix kalkulasi").
- [ ] Klik **Save**, kemudian lanjut ke **Review release**.
- [ ] Klik eksekusi: **Start rollout**.

### Phase 4: Post-Release Cleanup
- [ ] Beri penanda rilis ini pada GitHub Git (contoh jalankan: `git tag v1.0.2` dilanjut `git push --tags`).
- [ ] Pantau log server/backend setelah update untuk melihat indikasi *crash/downtime*.

---

### 🔁 Repeatable Release Flow (Prosedur Eksekusi Update)
Tiap kali selesai menyusun fitur/halaman baru, rutinitas andalan Anda hanyalah:
1. Centang **Preparation** (Sekali lagi: Naikkan versi `versionCode`!).
2. Centang **Build App Bundle**.
3. Centang **Release**.
Abaikan segala urusan *setup keystore* yang rumit, cukup jalankan siklus di atas layaknya pabrik.

---

### ⚠️ Critical Checks (Jangan Sampai Lewat)
- [ ] **Lupa +1 `versionCode`**: Langsung tertolak keras oleh Play Store saat melempar file `.aab`. Pastikan angka penanda upload senantiasa bertambah.
- [ ] **Lupa flag `--no-tree-shake-icons`**: File akan lolos upload sempurna, TAPI saat digunakan *user*, semua ikon bakal berupa kotak [X] silang yang jelek!
- [ ] **Lupa cabut Testing URL**: Mengirimkan aplikasi Live berisi koneksi ke *localhost* atau IP rumah Anda. 100% aplikasinya akan gagal memuat data (*blank*).
- [ ] **Menimpa `.jks` file**: File `upload-keystore.jks` adalah jantung project Anda. Bila raib atau tersalin timpa berkas baru, maka Anda gagal update aplikasi selamanya dan wajib buat profil aplikasi baru di toko app.

---

### 🧪 Verification
*Cara memastikan tidak ada insiden konyol menanti:*

- [ ] **Verifikasi Lokal**: Sebelum compile `.aab`, hubungkan HP asli, dan jalankan uji rilis:
  ```bash
  flutter run --release --no-tree-shake-icons
  ```
  Gulir layar *Insights*, ketik data *Add Transaction*, pastikan font dan ikon tampak luar biasa.

- [ ] **Verifikasi Cloud**: Tes unggah pada bagian label *Internal Testing*. Cek notifikasi di tab *Warnings*. Apabila peringatan murni kuning (semisal kode obfuscation), bisa Anda hantam jalan terus. Bila ada pesan eror warna merah terang, tunda perilisan.

---

### 🔥 Optional Automation (Level Up Workflow)
Bila ingin berhenti menekan baris command secara manual, jalankan saran ini kelak:
- **Fastlane Deploy**: Install modul `fastlane`. Melalui sebuah skrip `.rb`, terminal otomatis melempar file compilasi langsung ke cloud konsol play store tanpa Anda meraba GUI web. Panggilan komandonya cukup `fastlane deploy`.
- **GitHub Actions (CI/CD)**: Konfigurasikan file `.yaml` Github Action. Cukup tekan *Release* di web GitHub, lalu komputer serverlah yang otomatis mem-*build* file `.aab` ini selama Anda tidur.
