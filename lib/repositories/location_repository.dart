import 'package:dio/dio.dart';
import 'package:lautanrejeki/config/app_config.dart';

class LocationRepository {
  Future<Dio> _getDio() async {
    final baseUrl = await AppConfig.getBaseUrl();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, dynamic>{};
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    return Dio(BaseOptions(baseUrl: '$baseUrl/', headers: headers));
  }

  Future<void> startDelivery(String token, double lat, double lng) async {
    final dio = await _getDio();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    await dio.post('api/driver/start',
      data: {'latitude': lat, 'longitude': lng},
      options: Options(headers: headers),
    );
  }

  Future<void> updateLocation(String token, double lat, double lng) async {
    final dio = await _getDio();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    await dio.post('api/driver/update-location',
      data: {'latitude': lat, 'longitude': lng},
      options: Options(headers: headers),
    );
  }

  Future<void> finishDelivery(String token) async {
    final dio = await _getDio();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    await dio.post('api/driver/finish',
      options: Options(headers: headers),
    );
  }

  Future<List<Map<String, dynamic>>> getActiveDrivers(String token) async {
    final dio = await _getDio();
    final companyId = await AppConfig.getCompanyId();
    final headers = <String, String>{'Authorization': 'Bearer $token'};
    if (companyId != null && companyId.isNotEmpty) headers['X-Company-Id'] = companyId;
    final response = await dio.get('api/admin/drivers/active',
      options: Options(headers: headers),
    );
    return List<Map<String, dynamic>>.from(response.data['data']);
  }
}