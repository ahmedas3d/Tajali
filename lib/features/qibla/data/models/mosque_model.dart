import '../../../../core/utils/helpers.dart';

class MosqueModel {
  const MosqueModel({
    required this.nameAr,
    required this.lat,
    required this.lon,
    required this.distanceMeters,
  });

  final String nameAr;
  final double lat;
  final double lon;
  final double distanceMeters;

  String get formattedDistance {
    if (distanceMeters < 1000) {
      final m = TimeFormatter.toIndicDigits(distanceMeters.round().toString());
      return 'على بعد $m م';
    }
    final km = (distanceMeters / 1000).toStringAsFixed(1);
    return 'على بعد ${TimeFormatter.toIndicDigits(km)} كم';
  }

  String get mapsUrl {
    final name = Uri.encodeComponent(nameAr);
    return 'geo:$lat,$lon?q=$lat,$lon($name)';
  }

  String get fallbackMapsUrl =>
      'https://maps.google.com/maps?q=$lat,$lon';
}
