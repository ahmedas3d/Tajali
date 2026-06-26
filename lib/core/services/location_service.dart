import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationException implements Exception {
  const LocationException(this.message);
  final String message;
  @override
  String toString() => 'LocationException: $message';
}

class LocationService {
  static const _timeout = Duration(seconds: 10);

  Future<Position> getCurrentPosition() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException('permission_denied');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(_timeout);
    } on TimeoutException {
      final last = await getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException('timeout_no_cache');
    } catch (_) {
      final last = await getLastKnownPosition();
      if (last != null) return last;
      throw const LocationException('unavailable');
    }
  }

  Future<Position?> getLastKnownPosition() =>
      Geolocator.getLastKnownPosition();

  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();
}
