import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/mosque_model.dart';
import '../data/models/qibla_model.dart';
import '../data/services/mosque_service.dart';
import '../data/services/qibla_service.dart';
import '../../../core/services/location_service.dart';

// ── Singleton services ────────────────────────────────────────────────────────

final _qiblaService = QiblaService();
final _mosqueService = MosqueService();
final _locationService = LocationService();

// ── Location ──────────────────────────────────────────────────────────────────

/// GPS position specifically for the Qibla screen. Uses real GPS regardless
/// of any manual city selection made in the prayer times screen.
final qiblaLocationProvider = FutureProvider<Position>((ref) async {
  // Watch service status to detect mid-session revocation.
  final status = await Geolocator.checkPermission();
  if (status == LocationPermission.denied ||
      status == LocationPermission.deniedForever) {
    throw const LocationException('permission_denied');
  }
  return _locationService.getCurrentPosition();
});

// ── Qibla direction (cached / fetched) ───────────────────────────────────────

final qiblaModelProvider = FutureProvider<QiblaModel>((ref) async {
  final position = await ref.watch(qiblaLocationProvider.future);
  return _qiblaService.getQibla(position.latitude, position.longitude);
});

final cachedQiblaModelProvider = FutureProvider<QiblaModel?>((ref) async {
  return _qiblaService.getCached();
});

// ── City name ─────────────────────────────────────────────────────────────────

final cityNameProvider = FutureProvider<String>((ref) async {
  final model = await ref.watch(qiblaModelProvider.future);
  return model.cityName;
});

// ── Compass heading (smoothed) ────────────────────────────────────────────────

Stream<double> _smoothedHeadingStream() async* {
  const alpha = 0.15;
  double? smoothed;

  await for (final event in FlutterCompass.events ?? const Stream.empty()) {
    final heading = event.heading;
    if (heading == null) continue;

    if (smoothed == null) {
      smoothed = heading;
    } else {
      // Shortest-angle interpolation to avoid 359° → 1° wrap-around spin.
      double delta = heading - smoothed;
      while (delta > 180) { delta -= 360; }
      while (delta < -180) { delta += 360; }
      smoothed = (smoothed + alpha * delta + 360) % 360;
    }
    yield smoothed!;
  }
}

final compassHeadingProvider = StreamProvider<double>((ref) {
  return _smoothedHeadingStream();
});

// ── Compass accuracy ──────────────────────────────────────────────────────────

final compassAccuracyProvider = StreamProvider<AccuracyLevel>((ref) async* {
  await for (final event in FlutterCompass.events ?? const Stream.empty()) {
    yield accuracyFromSensor(event.accuracy);
  }
});

// ── Qibla rotation (derived) ─────────────────────────────────────────────────

/// Degrees to rotate the compass widget so its Qibla needle points toward Mecca.
final qiblaRotationProvider = Provider<double>((ref) {
  final direction = ref.watch(qiblaModelProvider).valueOrNull?.direction ?? 0;
  final heading = ref.watch(compassHeadingProvider).valueOrNull ?? 0;
  return (direction - heading + 360) % 360;
});

// ── Nearest mosque (live, no cache) ──────────────────────────────────────────

final nearestMosqueProvider = FutureProvider<MosqueModel?>((ref) async {
  final positionAsync = ref.watch(qiblaLocationProvider);
  return positionAsync.when(
    data: (pos) => _mosqueService.findNearest(pos.latitude, pos.longitude),
    loading: () => null,
    error: (_, __) => null,
  );
});

// ── Service status watcher (mid-session permission revocation) ────────────────

final locationServiceStatusProvider = StreamProvider<ServiceStatus>((ref) {
  return Geolocator.getServiceStatusStream();
});
