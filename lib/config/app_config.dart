import 'package:shared_preferences/shared_preferences.dart';

/// Sumber kebenaran tunggal untuk semua konfigurasi aplikasi.
/// - BASE_URL bisa diubah admin lewat settings, atau pakai default dari build.
/// - Koordinat kantor disimpan di SharedPreferences, bisa diatur per-kantor.
class AppConfig {
  // ─── Kunci SharedPreferences ───────────────────────────────────────────────
  static const _keyBaseUrl = 'config_base_url';
  static const _keyOfficeLat = 'config_office_lat';
  static const _keyOfficeLng = 'config_office_lng';
  static const _keyOfficeRadius = 'config_office_radius';
  static const _keyCompanyId = 'config_company_id';

  // ─── Default dari --dart-define (di-inject saat build) ────────────────────
  // Jalankan: flutter build apk --dart-define=BASE_URL=https://api.kantorku.com
  static const String _defaultBaseUrl =
  String.fromEnvironment('BASE_URL', defaultValue: 'https://api.lautanrejeki.id');

  static final double _defaultLat = double.tryParse(
    const String.fromEnvironment('OFFICE_LAT'),
  ) ?? -6.197728;

  static final double _defaultLng = double.tryParse(
    const String.fromEnvironment('OFFICE_LNG'),
  ) ?? 106.758653;

  static final double _defaultRadius = double.tryParse(
    const String.fromEnvironment('OFFICE_RADIUS'),
  ) ?? 100.0;

  // ─── Cache in-memory (hindari baca prefs setiap request) ──────────────────
  static String? _cachedBaseUrl;
  static double? _cachedLat;
  static double? _cachedLng;
  static double? _cachedRadius;
  static String? _cachedCompanyId;

  // ══════════════════════════════════════════════════════════════════════════
  // GETTERS — ASYNC (baca dari SharedPreferences, fallback ke default build)
  // ══════════════════════════════════════════════════════════════════════════

  static Future<String> getBaseUrl() async {
    if (_cachedBaseUrl != null) return _cachedBaseUrl!;
    final prefs = await SharedPreferences.getInstance();
    _cachedBaseUrl = prefs.getString(_keyBaseUrl) ?? _defaultBaseUrl;
    return _cachedBaseUrl!;
  }

  static Future<double> getOfficeLat() async {
    if (_cachedLat != null) return _cachedLat!;
    final prefs = await SharedPreferences.getInstance();
    _cachedLat = prefs.getDouble(_keyOfficeLat) ?? _defaultLat;
    return _cachedLat!;
  }

  static Future<double> getOfficeLng() async {
    if (_cachedLng != null) return _cachedLng!;
    final prefs = await SharedPreferences.getInstance();
    _cachedLng = prefs.getDouble(_keyOfficeLng) ?? _defaultLng;
    return _cachedLng!;
  }

  static Future<double> getOfficeRadius() async {
    if (_cachedRadius != null) return _cachedRadius!;
    final prefs = await SharedPreferences.getInstance();
    _cachedRadius = prefs.getDouble(_keyOfficeRadius) ?? _defaultRadius;
    return _cachedRadius!;
  }

  /// Get currently selected company id for multi-tenant support.
  /// Returns null when not set (app will use server defaults).
  static Future<String?> getCompanyId() async {
    if (_cachedCompanyId != null) return _cachedCompanyId;
    final prefs = await SharedPreferences.getInstance();
    _cachedCompanyId = prefs.getString(_keyCompanyId);
    return _cachedCompanyId;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SETTERS — dipakai dari halaman Admin Settings
  // ══════════════════════════════════════════════════════════════════════════

  static Future<void> setBaseUrl(String url) async {
    // Pastikan tidak ada trailing slash ganda
    final clean = url.trim().replaceAll(RegExp(r'/+$'), '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyBaseUrl, clean);
    _cachedBaseUrl = clean;
  }

  static Future<void> setOfficeLocation({
    required double lat,
    required double lng,
    double? radius,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyOfficeLat, lat);
    await prefs.setDouble(_keyOfficeLng, lng);
    if (radius != null) {
      await prefs.setDouble(_keyOfficeRadius, radius);
      _cachedRadius = radius;
    }
    _cachedLat = lat;
    _cachedLng = lng;
  }

  /// Set selected company id. Pass `null` to remove selection.
  static Future<void> setCompanyId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null || id.trim().isEmpty) {
      await prefs.remove(_keyCompanyId);
      _cachedCompanyId = null;
      return;
    }
    final clean = id.trim();
    await prefs.setString(_keyCompanyId, clean);
    _cachedCompanyId = clean;
  }

  /// Reset semua config ke default build-time
  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyBaseUrl);
    await prefs.remove(_keyOfficeLat);
    await prefs.remove(_keyOfficeLng);
    await prefs.remove(_keyOfficeRadius);
    await prefs.remove(_keyCompanyId);
    _cachedBaseUrl = null;
    _cachedLat = null;
    _cachedLng = null;
    _cachedRadius = null;
    _cachedCompanyId = null;
  }

  /// Invalidate cache (panggil setelah set supaya getter ambil nilai baru)
  static void invalidateCache() {
    _cachedBaseUrl = null;
    _cachedLat = null;
    _cachedLng = null;
    _cachedRadius = null;
    _cachedCompanyId = null;
  }

  /// Helper: kembalikan semua config aktif sebagai Map (untuk debug / UI)
  static Future<Map<String, dynamic>> getAll() async {
    return {
      'baseUrl': await getBaseUrl(),
      'officeLat': await getOfficeLat(),
      'officeLng': await getOfficeLng(),
      'officeRadius': await getOfficeRadius(),
      'companyId': await getCompanyId(),
    };
  }
}