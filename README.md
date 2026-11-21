# Worksheet 10 — KosFinder Device Demo (STANDALONE)

**Tidak menggunakan kode, tabel, login, atau role dari Worksheet 9.**

## A. Buat project Flutter baru

```bash
flutter create kosfinder_device_demo
cd kosfinder_device_demo
flutter pub add image_picker geolocator path_provider shared_preferences supabase_flutter sensors_plus
flutter pub get
```

Salin folder `lib/` pada ZIP ini ke `lib/` di project baru (timpa `lib/main.dart`).
Salin juga `test/widget_test.dart` dari ZIP untuk mengganti test default Flutter yang masih
merujuk class `MyApp` bawaan.

## B. Permission platform

**Android:** tambahkan isi `platform/android_manifest_snippet.xml` ke dalam `<manifest>` pada
`android/app/src/main/AndroidManifest.xml`, langsung sebelum `<application>`.
Cek `compileSdk` sesuai requirement `geolocator` (contoh minimal 35; lihat pub.dev).

**iOS:** tambahkan isi `platform/ios_info_plist_snippet.xml` ke dalam `<dict>` di
`ios/Runner/Info.plist`. Kamera/GPS dan sensor memerlukan perangkat/emulator yang mendukung.

## C. Praktik inti — lokal (TIDAK PERLU SUPABASE)

```bash
flutter run
```

Coba kamera/galeri, GPS dan penolakan izin, lalu `Simpan Draft Lokal`.
Tutup aplikasi, buka kembali: data harus tetap ada.

## D. Praktik tambahan — Supabase Storage (mandiri)

1. Buat project Supabase **baru** atau gunakan project latihan kosong.
2. `Authentication > Settings/Providers`: aktifkan **Allow anonymous sign-ins**.
3. `Storage > New bucket`: nama `kosfinder-demo`; **Public: ON** untuk foto demo;
   maksimal 5 MB; MIME hanya `image/jpeg` dan `image/png`.
4. `SQL Editor`: jalankan `sql/storage_policy.sql`.
5. Dapatkan `Project URL` dan **publishable key** pada halaman API project.
6. Jalankan:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=YOUR_PUBLISHABLE_KEY
```

Catatan: jika credential belum diisi, tombol upload memang nonaktif dan semua fitur lokal tetap berjalan.
Saat upload pertama, SDK melakukan anonymous sign-in. Ini **bukan** API key anonim; ia
membentuk user Supabase sementara dengan `auth.uid()` unik. Jika aplikasi dihapus/
penyimpanan aplikasi dihapus atau user sign out, akun anonymous lama tidak dapat dipulihkan.

**JANGAN** menggunakan service_role/secret key pada Flutter. Public bucket cocok hanya untuk
foto uji non-sensitif. Untuk produk sungguhan gunakan identitas nyata, antiabuse/CAPTCHA,
kuota dan kebijakan retensi, serta pertimbangkan private bucket + signed URL.

## E. Verifikasi

```bash
flutter analyze
flutter test
flutter run
```

Uji setidaknya: galeri cancel, izin lokasi deny, GPS off, restart app,
upload tanpa internet, dan upload berhasil jika modul Supabase diaktifkan.

Referensi resmi (diperiksa 10 November 2026):
- https://pub.dev/packages/image_picker
- https://pub.dev/packages/geolocator
- https://pub.dev/packages/shared_preferences
- https://pub.dev/packages/path_provider
- https://pub.dev/packages/sensors_plus
- https://supabase.com/docs/guides/auth/auth-anonymous
- https://supabase.com/docs/guides/storage/security/access-control
