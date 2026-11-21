/// Konfigurasi cloud opsional; fitur kamera/GPS/draft tetap berjalan tanpa ini.
/// Isi melalui --dart-define ketika menjalankan Flutter.
class CloudConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get enabled => url.isNotEmpty && publishableKey.isNotEmpty;
}
