import 'package:hive_flutter/hive_flutter.dart';

part 'tasbih_session_model.g.dart';

@HiveType(typeId: 15)
class TasbihSessionModel extends HiveObject {
  TasbihSessionModel({
    required this.dhikrType,
    required this.currentCount,
    required this.completedRounds,
    required this.target,
  });

  @HiveField(0)
  String dhikrType;

  @HiveField(1)
  int currentCount;

  @HiveField(2)
  int completedRounds;

  @HiveField(3)
  int target;

  TasbihSessionModel copyWith({
    String? dhikrType,
    int? currentCount,
    int? completedRounds,
    int? target,
  }) {
    return TasbihSessionModel(
      dhikrType: dhikrType ?? this.dhikrType,
      currentCount: currentCount ?? this.currentCount,
      completedRounds: completedRounds ?? this.completedRounds,
      target: target ?? this.target,
    );
  }
}
