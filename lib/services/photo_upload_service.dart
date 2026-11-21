import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../cloud_config.dart';

class PhotoUploadResult {
  const PhotoUploadResult(this.storagePath, this.publicUrl);
  final String storagePath;
  final String publicUrl;
}

/// Layanan ini HANYA dipanggil jika mahasiswa memilih praktik cloud.
class PhotoUploadService {
  Future<PhotoUploadResult> upload(File photo) async {
    if (!CloudConfig.enabled) {
      throw StateError(
        'Supabase belum dikonfigurasi. Jalankan dengan --dart-define '
        'atau gunakan Simpan Draft Lokal.',
      );
    }

    final client = Supabase.instance.client;
    // Anonymous Sign-In bukan tanpa otorisasi: ini membuat auth.uid() unik.
    if (client.auth.currentUser == null) {
      await client.auth.signInAnonymously();
    }
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sesi anonymous Supabase tidak berhasil dibuat.');
    }

    final ext = photo.path.split('.').last.toLowerCase();
    if (!{'jpg', 'jpeg', 'png'}.contains(ext)) {
      throw const FormatException('Format foto tidak didukung.');
    }
    if (await photo.length() > 5 * 1024 * 1024) {
      throw const FormatException('Ukuran foto maksimal 5 MB.');
    }

    // Policy Storage mengizinkan tulis HANYA di folder milik auth.uid().
    final objectPath = '$userId/${DateTime.now().microsecondsSinceEpoch}.$ext';
    final returnedPath = await client.storage.from('kosfinder-demo').upload(
          objectPath,
          photo,
          fileOptions: FileOptions(
            upsert: false,
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
          ),
        );
    final publicUrl =
        client.storage.from('kosfinder-demo').getPublicUrl(returnedPath);
    return PhotoUploadResult(returnedPath, publicUrl);
  }
}
