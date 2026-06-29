import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tajali/features/qibla/data/models/qibla_model.dart';
import 'package:tajali/features/qibla/presentation/widgets/compass_widget.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  group('CompassWidget', () {
    testWidgets('renders without throwing for each accuracy level', (tester) async {
      for (final level in AccuracyLevel.values) {
        await tester.pumpWidget(wrap(CompassWidget(
          rotationTurns: 0.0,
          accuracy: level,
        )));
        await tester.pump();
        expect(find.byType(CompassWidget), findsOneWidget);
      }
    });

    testWidgets('shows accuracy badge text for high accuracy', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.0,
        accuracy: AccuracyLevel.high,
      )));
      await tester.pump();
      expect(find.text('دقة عالية'), findsOneWidget);
    });

    testWidgets('shows accuracy badge text for medium accuracy', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.0,
        accuracy: AccuracyLevel.medium,
      )));
      await tester.pump();
      expect(find.text('دقة متوسطة'), findsOneWidget);
    });

    testWidgets('shows accuracy badge text for low accuracy', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.0,
        accuracy: AccuracyLevel.low,
      )));
      await tester.pump();
      expect(find.text('دقة منخفضة'), findsOneWidget);
    });

    testWidgets('shows no-sensor label when hasCompassSensor is false', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.0,
        accuracy: AccuracyLevel.low,
        hasCompassSensor: false,
      )));
      await tester.pump();
      expect(find.text('لا يوجد بوصلة على هذا الجهاز'), findsOneWidget);
    });

    testWidgets('does NOT show no-sensor label when hasCompassSensor is true', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.0,
        accuracy: AccuracyLevel.high,
      )));
      await tester.pump();
      expect(find.text('لا يوجد بوصلة على هذا الجهاز'), findsNothing);
    });

    testWidgets('AnimatedRotation receives correct turns value', (tester) async {
      await tester.pumpWidget(wrap(const CompassWidget(
        rotationTurns: 0.25,
        accuracy: AccuracyLevel.high,
      )));
      await tester.pump();
      final rotation = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation));
      expect(rotation.turns, closeTo(0.25, 0.001));
    });
  });
}
