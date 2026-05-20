import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lautanrejeki/config/app_config.dart';
import 'package:lautanrejeki/src/colors.dart';

/// Halaman pengaturan untuk admin: mengatur URL backend dan koordinat kantor.
/// Akses dari ProfilePage > tombol Settings (hanya tampil untuk role admin).
class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final _formKey = GlobalKey<FormState>();

  final _urlCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _radiusCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _successMsg;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await AppConfig.getAll();
    setState(() {
      _urlCtrl.text = config['baseUrl'] as String;
      _latCtrl.text = (config['officeLat'] as double).toString();
      _lngCtrl.text = (config['officeLng'] as double).toString();
      _radiusCtrl.text = (config['officeRadius'] as double).toString();
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _successMsg = null;
    });

    try {
      await AppConfig.setBaseUrl(_urlCtrl.text.trim());
      await AppConfig.setOfficeLocation(
        lat: double.parse(_latCtrl.text.trim()),
        lng: double.parse(_lngCtrl.text.trim()),
        radius: double.parse(_radiusCtrl.text.trim()),
      );

      setState(() => _successMsg = 'Pengaturan berhasil disimpan!');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _reset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset ke default?'),
        content: const Text(
          'Semua pengaturan akan dikembalikan ke nilai bawaan dari build aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await AppConfig.resetToDefaults();
    await _loadConfig();

    setState(() => _successMsg = 'Berhasil direset ke default.');
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan Admin'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Catatan ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: const Text(
                  'Pengaturan ini disimpan di perangkat. '
                      'Jika aplikasi di-uninstall, nilai akan kembali ke default build.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),

              const SizedBox(height: 28),

              // ── Seksi URL Backend ─────────────────────────────────
              _sectionTitle('🌐  URL Backend API'),
              const SizedBox(height: 10),
              _buildTextField(
                controller: _urlCtrl,
                label: 'Base URL',
                hint: 'https://api.kantorku.com',
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'URL wajib diisi';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) {
                    return 'URL tidak valid (contoh: http://192.168.1.1:8000)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 28),

              // ── Seksi Lokasi Kantor ───────────────────────────────
              _sectionTitle('📍  Koordinat Kantor'),
              const SizedBox(height: 6),
              const Text(
                'Cari koordinat kantor di Google Maps: tekan lama pada titik kantor, '
                    'lalu salin angka latitude & longitude.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _latCtrl,
                      label: 'Latitude',
                      hint: '-6.197728',
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib';
                        final d = double.tryParse(v.trim());
                        if (d == null || d < -90 || d > 90) {
                          return 'Tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _lngCtrl,
                      label: 'Longitude',
                      hint: '106.758653',
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Wajib';
                        final d = double.tryParse(v.trim());
                        if (d == null || d < -180 || d > 180) {
                          return 'Tidak valid';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _radiusCtrl,
                label: 'Radius absensi (meter)',
                hint: '100',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Wajib';
                  final d = double.tryParse(v.trim());
                  if (d == null || d <= 0) return 'Harus > 0';
                  return null;
                },
              ),

              const SizedBox(height: 36),

              // ── Pesan sukses ──────────────────────────────────────
              if (_successMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      const SizedBox(width: 8),
                      Text(_successMsg!, style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Tombol Simpan ─────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Simpan Pengaturan',
                      style: TextStyle(fontSize: 16)),
                ),
              ),

              const SizedBox(height: 12),

              // ── Tombol Reset ──────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Reset ke Default Build'),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textColor,
    ),
  );

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        validator: validator,
      );
}