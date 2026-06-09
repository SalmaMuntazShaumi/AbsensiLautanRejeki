import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lautanrejeki/repositories/location_repository.dart';
import 'package:lautanrejeki/services/session_service.dart';
import 'package:lautanrejeki/src/colors.dart';

class LocationPage extends StatefulWidget {
  final String role;

  const LocationPage({super.key, required this.role});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final LocationRepository _locationRepo = LocationRepository();
  final MapController _mapController = MapController();

  bool get _isAdmin => widget.role.toLowerCase() == 'admin';

  // Driver state
  bool _isOnDelivery = false;
  bool _isLoading = false;
  LatLng? _currentPosition;
  Timer? _locationUpdateTimer;

  // Admin state
  List<Map<String, dynamic>> _activeDrivers = [];
  Timer? _adminRefreshTimer;

  String _token = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await SessionService.getToken();
    if (token == null) return;
    _token = token;

    if (_isAdmin) {
      await _loadActiveDrivers();
      _adminRefreshTimer = Timer.periodic(
        const Duration(seconds: 10),
            (_) => _loadActiveDrivers(),
      );
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      // ← hapus _mapController.move() dari sini
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _startDelivery() async {
    if (_currentPosition == null) return;

    setState(() => _isLoading = true);
    try {
      await _locationRepo.startDelivery(
        _token,
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );

      setState(() => _isOnDelivery = true);

      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 10),
            (_) => _updateLocation(),
      );

      _showSnackbar('Perjalanan dimulai!', Colors.green);
    } catch (e) {
      print('START DELIVERY ERROR: $e'); // ← tambah ini
      _showSnackbar('Gagal memulai perjalanan: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      final newPos = LatLng(position.latitude, position.longitude);

      setState(() => _currentPosition = newPos);
      _mapController.move(newPos, 15);

      await _locationRepo.updateLocation(
        _token,
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> _finishDelivery() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Selesai Pengiriman'),
        content: const Text('Apakah Anda sudah sampai di tujuan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _locationRepo.finishDelivery(_token);
      _locationUpdateTimer?.cancel();
      setState(() => _isOnDelivery = false);
      _showSnackbar('Pengiriman selesai!', Colors.green);
    } catch (e) {
      _showSnackbar('Gagal menyelesaikan pengiriman', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadActiveDrivers() async {
    try {
      final drivers = await _locationRepo.getActiveDrivers(_token);
      setState(() => _activeDrivers = drivers);
    } catch (e) {
      print('Error loading drivers: $e');
    }
  }

  void _focusDriver(Map<String, dynamic> driver) {
    final lat = double.parse(driver['latitude'].toString());
    final lng = double.parse(driver['longitude'].toString());
    _mapController.move(LatLng(lat, lng), 16);
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    _adminRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _isAdmin ? 'Monitor Driver' : 'Pengiriman',
          style: const TextStyle(
            color: AppColors.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: _isAdmin
            ? [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryColor),
            onPressed: _loadActiveDrivers,
          ),
        ]
            : null,
      ),
      body: _isAdmin ? _buildAdminView() : _buildDriverView(),
    );
  }

  // ─── DRIVER VIEW ──────────────────────────────────────────────────────────

  Widget _buildDriverView() {
    return Column(
      children: [
        // Status card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isOnDelivery
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _isOnDelivery ? Icons.local_shipping : Icons.home,
                  color: _isOnDelivery ? Colors.green : Colors.grey,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOnDelivery ? 'Sedang Bertugas' : 'Siap Bertugas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _isOnDelivery
                            ? Colors.green
                            : AppColors.textColor,
                      ),
                    ),
                    Text(
                      _isOnDelivery
                          ? 'Lokasi Anda sedang dilacak'
                          : 'Tekan Mulai untuk memulai pengiriman',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Live indicator
              if (_isOnDelivery)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.green, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Map
        Expanded(
          child: _currentPosition == null
              ? const Center(child: CircularProgressIndicator())
              : ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition ?? const LatLng(-6.2088, 106.8456),
                initialZoom: 15,
                onMapReady: () {
                  // Sekarang aman pakai mapController
                  if (_currentPosition != null) {
                    _mapController.move(_currentPosition!, 15);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.lautanrejeki.app',
                ),
                MarkerLayer(
                  markers: [
                    if (_currentPosition != null)
                      Marker(
                        point: _currentPosition!,
                        width: 50,
                        height: 50,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryColor
                                    .withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_shipping,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Button
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                _isOnDelivery ? Colors.red : AppColors.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _isLoading
                  ? null
                  : _isOnDelivery
                  ? _finishDelivery
                  : _startDelivery,
              icon: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(
                  _isOnDelivery ? Icons.stop_circle : Icons.play_circle),
              label: Text(
                _isLoading
                    ? 'Memproses...'
                    : _isOnDelivery
                    ? 'Selesai'
                    : 'Mulai',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── ADMIN VIEW ───────────────────────────────────────────────────────────

  Widget _buildAdminView() {
    // Default center Jakarta
    final LatLng mapCenter = _activeDrivers.isNotEmpty
        ? LatLng(
      double.parse(_activeDrivers[0]['latitude'].toString()),
      double.parse(_activeDrivers[0]['longitude'].toString()),
    )
        : const LatLng(-6.2088, 106.8456);

    return Column(
      children: [
        // Map
        Expanded(
          flex: 3,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: 12,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.lautanrejeki.app',
              ),
              MarkerLayer(
                markers: _activeDrivers.map((driver) {
                  final lat = double.parse(driver['latitude'].toString());
                  final lng = double.parse(driver['longitude'].toString());
                  return Marker(
                    point: LatLng(lat, lng),
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () => _showDriverInfo(driver),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                  AppColors.primaryColor.withOpacity(0.4),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              driver['name'].toString().split(' ')[0],
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        // Driver list
        Expanded(
          flex: 2,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Text(
                        'Driver Aktif',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_activeDrivers.length}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _activeDrivers.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping_outlined,
                            size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Semua driver sedang istirahat',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _activeDrivers.length,
                    itemBuilder: (ctx, i) =>
                        _buildDriverCard(_activeDrivers[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver) {
    return GestureDetector(
      onTap: () => _focusDriver(driver),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primaryColor.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.15),
              child: Text(
                driver['name'][0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    driver['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Text(
                    'Sedang dalam perjalanan',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, color: Colors.green, size: 8),
                  SizedBox(width: 4),
                  Text(
                    'Aktif',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.my_location,
                color: AppColors.primaryColor, size: 18),
          ],
        ),
      ),
    );
  }

  void _showDriverInfo(Map<String, dynamic> driver) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.15),
                  child: Text(
                    driver['name'][0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Sedang dalam perjalanan',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.access_time, 'Mulai',
                driver['started_at']?.toString() ?? '-'),
            const SizedBox(height: 8),
            _infoRow(
              Icons.location_on,
              'Koordinat',
              '${driver['latitude']}, ${driver['longitude']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryColor),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}