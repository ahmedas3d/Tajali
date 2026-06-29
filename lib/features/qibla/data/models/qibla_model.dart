import 'dart:io';

enum AccuracyLevel { low, medium, high }

AccuracyLevel accuracyFromSensor(double? raw) {
  if (raw == null) return AccuracyLevel.low;
  if (Platform.isIOS) {
    if (raw < 0) return AccuracyLevel.low;
    if (raw < 5) return AccuracyLevel.high;
    if (raw < 20) return AccuracyLevel.medium;
    return AccuracyLevel.low;
  }
  // Android: SensorManager.SENSOR_STATUS_* (0=unreliable,1=low,2=medium,3=high)
  final status = raw.round();
  if (status >= 3) return AccuracyLevel.high;
  if (status == 2) return AccuracyLevel.medium;
  return AccuracyLevel.low;
}

class QiblaModel {
  const QiblaModel({
    required this.direction,
    required this.distanceKm,
    required this.cityName,
    required this.refLat,
    required this.refLon,
  });

  final double direction;    // degrees from North toward Mecca
  final double distanceKm;   // great-circle distance to Mecca
  final String cityName;     // reverse-geocoded display label
  final double refLat;       // latitude used for API call (cache invalidation)
  final double refLon;       // longitude used for API call (cache invalidation)
}
