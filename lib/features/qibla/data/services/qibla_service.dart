import 'dart:math';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/qibla_model.dart';

const _meccaLat = 21.3891;
const _meccaLon = 39.8579;

const _kDirection = 'qibla_direction';
const _kCity = 'qibla_city';
const _kDistance = 'qibla_distance_km';
const _kRefLat = 'qibla_ref_lat';
const _kRefLon = 'qibla_ref_lon';

const _cacheInvalidationKm = 50.0;

double haversineKm(double lat1, double lon1, double lat2, double lon2) {
  const r = 6371.0;
  final dLat = _rad(lat2 - lat1);
  final dLon = _rad(lon2 - lon1);
  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}

double _rad(double deg) => deg * pi / 180;

String cardinalFromDegrees(double deg) {
  final d = ((deg % 360) + 360) % 360;
  if (d < 22.5 || d >= 337.5) return 'N';
  if (d < 67.5) return 'NE';
  if (d < 112.5) return 'E';
  if (d < 157.5) return 'SE';
  if (d < 202.5) return 'S';
  if (d < 247.5) return 'SW';
  if (d < 292.5) return 'W';
  return 'NW';
}

class QiblaService {
  QiblaService({Dio? dio}) : _dio = dio ?? Dio();
  final Dio _dio;

  Future<QiblaModel> getQibla(double lat, double lon) async {
    final prefs = await SharedPreferences.getInstance();

    if (_cacheValid(prefs, lat, lon)) {
      return QiblaModel(
        direction: prefs.getDouble(_kDirection)!,
        distanceKm: prefs.getDouble(_kDistance)!,
        cityName: prefs.getString(_kCity)!,
        refLat: prefs.getDouble(_kRefLat)!,
        refLon: prefs.getDouble(_kRefLon)!,
      );
    }

    final direction = await _fetchDirection(lat, lon);
    final distanceKm = haversineKm(lat, lon, _meccaLat, _meccaLon);
    final cityName = await _reverseGeocode(lat, lon);

    await _writeCache(prefs, direction, distanceKm, cityName, lat, lon);

    return QiblaModel(
      direction: direction,
      distanceKm: distanceKm,
      cityName: cityName,
      refLat: lat,
      refLon: lon,
    );
  }

  Future<QiblaModel?> getCached() async {
    final prefs = await SharedPreferences.getInstance();
    final direction = prefs.getDouble(_kDirection);
    if (direction == null) return null;
    return QiblaModel(
      direction: direction,
      distanceKm: prefs.getDouble(_kDistance) ?? 0,
      cityName: prefs.getString(_kCity) ?? '',
      refLat: prefs.getDouble(_kRefLat) ?? 0,
      refLon: prefs.getDouble(_kRefLon) ?? 0,
    );
  }

  bool _cacheValid(SharedPreferences prefs, double lat, double lon) {
    final refLat = prefs.getDouble(_kRefLat);
    final refLon = prefs.getDouble(_kRefLon);
    final direction = prefs.getDouble(_kDirection);
    if (refLat == null || refLon == null || direction == null) return false;
    return haversineKm(lat, lon, refLat, refLon) < _cacheInvalidationKm;
  }

  Future<double> _fetchDirection(double lat, double lon) async {
    final resp = await _dio.get(
      'https://api.aladhan.com/v1/qibla/$lat/$lon',
      options: Options(receiveTimeout: const Duration(seconds: 10)),
    );
    return (resp.data['data']['direction'] as num).toDouble();
  }

  Future<String> _reverseGeocode(double lat, double lon) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      if (placemarks.isEmpty) return _coordFallback(lat, lon);
      final p = placemarks.first;
      final city = p.locality ?? '';
      final country = p.country ?? '';
      if (city.isEmpty && country.isEmpty) return _coordFallback(lat, lon);
      if (city.isEmpty) return country;
      if (country.isEmpty) return city;
      return '$city، $country';
    } catch (_) {
      return _coordFallback(lat, lon);
    }
  }

  String _coordFallback(double lat, double lon) =>
      '${lat.toStringAsFixed(2)}°، ${lon.toStringAsFixed(2)}°';

  Future<void> _writeCache(
    SharedPreferences prefs,
    double direction,
    double distanceKm,
    String cityName,
    double lat,
    double lon,
  ) async {
    await prefs.setDouble(_kDirection, direction);
    await prefs.setDouble(_kDistance, distanceKm);
    await prefs.setString(_kCity, cityName);
    await prefs.setDouble(_kRefLat, lat);
    await prefs.setDouble(_kRefLon, lon);
  }
}
