import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../cloud_config.dart';
import '../services/device_location_service.dart';
import '../services/draft_repository.dart';
import '../services/photo_upload_service.dart';
import 'sensor_demo_page.dart';

class DeviceDemoPage extends StatefulWidget {
  const DeviceDemoPage({super.key});

  @override
  State<DeviceDemoPage> createState() => _DeviceDemoPageState();
}

class _DeviceDemoPageState extends State<DeviceDemoPage> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  final _drafts = DraftRepository();
  final _location = DeviceLocationService();
  final _uploader = PhotoUploadService();

  String? _photoPath;
  String? _storagePath;
  String? _publicUrl;
  double? _latitude;
  double? _longitude;
  LocationFailureType? _locationError;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _restoreLocalDraft();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _notice(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _restoreLocalDraft() async {
    try {
      final draft = await _drafts.load();
      if (!mounted) return;
      setState(() {
        _nameController.text = draft['name'] as String? ?? '';
        _photoPath = draft['photoPath'] as String?;
        _storagePath = draft['storagePath'] as String?;
        _publicUrl = draft['publicUrl'] as String?;
        final lat = draft['latitude'];
        final lng = draft['longitude'];
        _latitude = lat is num ? lat.toDouble() : null;
        _longitude = lng is num ? lng.toDouble() : null;
      });
      await _recoverInterruptedPicker();
    } catch (error) {
      _notice('Draft lokal belum dapat dibaca: $error');
    }
  }

  Future<void> _recoverInterruptedPicker() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final lost = await _picker.retrieveLostData();
    if (lost.isEmpty) return;
    if (lost.files != null && lost.files!.isNotEmpty) {
      await _acceptPhoto(lost.files!.first);
      _notice('Foto dari proses kamera/galeri yang terputus dipulihkan.');
    } else if (lost.exception != null) {
      _notice('Pemulihan foto gagal: ${lost.exception}');
    }
  }

  Future<void> _saveDraft({bool showMessage = true}) async {
    await _drafts.save({
      'name': _nameController.text.trim(),
      'photoPath': _photoPath,
      'latitude': _latitude,
      'longitude': _longitude,
      'storagePath': _storagePath,
      'publicUrl': _publicUrl,
    });
    if (showMessage) _notice('Draft berhasil disimpan di perangkat.');
  }

  Future<void> _acceptPhoto(XFile picked) async {
    final permanentPath = await _drafts.savePermanentPhoto(picked);
    if (!mounted) return;
    setState(() {
      _photoPath = permanentPath;
      _storagePath = null;
      _publicUrl = null;
    });
    await _saveDraft(showMessage: false);
  }

  Future<void> _choosePhoto(ImageSource source) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 80,
      );
      if (picked == null) {
        _notice('Pemilihan foto dibatalkan; draft tidak berubah.');
        return;
      }
      await _acceptPhoto(picked);
      _notice('Foto disalin ke penyimpanan permanen aplikasi.');
    } on PlatformException catch (error) {
      _notice('Kamera/galeri tidak tersedia (${error.code}). Cek izin perangkat.');
    } on FormatException catch (error) {
      _notice(error.message);
    } catch (error) {
      _notice('Gagal memilih foto: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _getLocation() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _locationError = null;
    });
    try {
      final position = await _location.getPosition();
      if (!mounted) return;
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      await _saveDraft(showMessage: false);
      _notice('Koordinat berhasil diambil dan tersimpan dalam draft.');
    } on LocationFailure catch (error) {
      if (!mounted) return;
      setState(() => _locationError = error.type);
      _notice(error.message);
    } on TimeoutException {
      _notice('Waktu mencari GPS habis. Coba dekat jendela/area terbuka.');
    } catch (error) {
      _notice('Lokasi tidak dapat diambil: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _upload() async {
    if (_busy || !CloudConfig.enabled) return;
    if (_nameController.text.trim().isEmpty) {
      _notice('Isi nama kos sebelum mengunggah foto.');
      return;
    }
    final path = _photoPath;
    if (path == null || !File(path).existsSync()) {
      _notice('Ambil/pilih foto terlebih dahulu.');
      return;
    }
    setState(() => _busy = true);
    try {
      final result = await _uploader.upload(File(path));
      if (!mounted) return;
      setState(() {
        _storagePath = result.storagePath;
        _publicUrl = result.publicUrl;
      });
      await _saveDraft(showMessage: false);
      _notice('Berhasil! Foto tersedia pada Supabase Storage.');
    } on AuthException catch (error) {
      _notice('Login anonymous Supabase gagal: ${error.message}');
    } on StorageException catch (error) {
      _notice('Upload ditolak Storage: ${error.message}');
    } catch (error) {
      _notice('Gagal upload: $error. Draft lokal tetap ada.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoExists = _photoPath != null && File(_photoPath!).existsSync();
    return Scaffold(
      appBar: AppBar(
        title: const Text('KosFinder · Device Demo'),
        actions: [
          IconButton(
            tooltip: 'Demo sensor',
            icon: const Icon(Icons.sensors),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SensorDemoPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            CloudConfig.enabled
                ? 'Mode: lokal + Supabase (tanpa Worksheet 9)'
                : 'Mode: lokal/offline (Supabase belum dikonfigurasi)',
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama kos (contoh: Kos Melati)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _choosePhoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
              ),
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _choosePhoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeri'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (photoExists)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_photoPath!), height: 200, fit: BoxFit.cover),
            )
          else
            const Text('Belum ada foto. Pilih foto JPG/PNG maksimal 5 MB.'),
          const Divider(height: 28),
          FilledButton.tonalIcon(
            onPressed: _busy ? null : _getLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('Ambil Koordinat GPS'),
          ),
          const SizedBox(height: 6),
          Text(
            _latitude == null || _longitude == null
                ? 'Koordinat: belum diisi (opsional)'
                : 'Lat: ${_latitude!.toStringAsFixed(6)}, '
                    'Lng: ${_longitude!.toStringAsFixed(6)}',
          ),
          if (_locationError == LocationFailureType.serviceDisabled)
            TextButton(
              onPressed: () => Geolocator.openLocationSettings(),
              child: const Text('Buka pengaturan layanan lokasi'),
            ),
          if (_locationError == LocationFailureType.deniedForever)
            TextButton(
              onPressed: () => Geolocator.openAppSettings(),
              child: const Text('Buka pengaturan izin aplikasi'),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy
                ? null
                : () async {
                    try {
                      await _saveDraft();
                    } catch (error) {
                      _notice('Gagal menyimpan draft: $error');
                    }
                  },
            icon: const Icon(Icons.save),
            label: const Text('Simpan Draft Lokal'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _busy || !CloudConfig.enabled ? null : _upload,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Upload Foto ke Supabase (opsional)'),
          ),
          if (!CloudConfig.enabled)
            const Text('Untuk mengaktifkan upload, lihat bagian Supabase di worksheet.'),
          if (_busy) const LinearProgressIndicator(),
          if (_storagePath != null) ...[
            const SizedBox(height: 14),
            const Text('Lokasi objek Storage:'),
            SelectableText(_storagePath!),
          ],
          if (_publicUrl != null) ...[
            const SizedBox(height: 8),
            const Text('URL foto publik:'),
            SelectableText(_publicUrl!),
          ],
          const SizedBox(height: 16),
          const Text(
            'GPS menunjukkan posisi ponsel, bukan otomatis posisi kos. '
            'Jangan unggah foto orang atau informasi pribadi untuk demo.',
          ),
        ],
      ),
    );
  }
}
