import 'package:dio/dio.dart';
import 'package:lautanrejeki/config/app_config.dart';

class LocationRepository {
  Future<Dio> _getDio() async {
    final baseUrl = await AppConfig.getBaseUrl();
    return Dio(BaseOptions(baseUrl: '$baseUrl/'));
  }

  Future<void> startDelivery(String token, double lat, double lng) async {
    final dio = await _getDio();
    await dio.post('api/driver/start',
      data: {'latitude': lat, 'longitude': lng},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> updateLocation(String token, double lat, double lng) async {
    final dio = await _getDio();
    await dio.post('api/driver/update-location',
      data: {'latitude': lat, 'longitude': lng},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> finishDelivery(String token) async {
    final dio = await _getDio();
    await dio.post('api/driver/finish',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<List<Map<String, dynamic>>> getActiveDrivers(String token) async {
    final dio = await _getDio();
    final response = await dio.get('api/admin/drivers/active',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }
}