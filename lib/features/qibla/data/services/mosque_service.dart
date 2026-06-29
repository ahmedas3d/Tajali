import 'package:dio/dio.dart';
import '../models/mosque_model.dart';
import 'qibla_service.dart';

class MosqueService {
  MosqueService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<MosqueModel?> findNearest(double lat, double lon) async {
    const query = '''
[out:json][timeout:10];
node["amenity"="place_of_worship"]["religion"="muslim"](around:2000,LAT,LON);
out 1;
''';
    final overpassQuery = query
        .replaceAll('LAT', lat.toStringAsFixed(6))
        .replaceAll('LON', lon.toStringAsFixed(6));

    try {
      final resp = await _dio.post(
        'https://overpass-api.de/api/interpreter',
        data: 'data=${Uri.encodeComponent(overpassQuery)}',
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      );

      final elements = resp.data['elements'] as List?;
      if (elements == null || elements.isEmpty) return null;

      final el = elements.first as Map<String, dynamic>;
      final mLat = (el['lat'] as num).toDouble();
      final mLon = (el['lon'] as num).toDouble();
      final tags = el['tags'] as Map<String, dynamic>? ?? {};
      final nameAr = (tags['name:ar'] ?? tags['name'] ?? 'مسجد').toString();
      final distanceMeters = haversineKm(lat, lon, mLat, mLon) * 1000;

      return MosqueModel(
        nameAr: nameAr,
        lat: mLat,
        lon: mLon,
        distanceMeters: distanceMeters,
      );
    } catch (_) {
      return null;
    }
  }
}
