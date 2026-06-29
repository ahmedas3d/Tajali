import 'package:hive_flutter/hive_flutter.dart';

part 'tasbih_history_entry.g.dart';

@HiveType(typeId: 16)
class TasbihHistoryEntry extends HiveObject {
  TasbihHistoryEntry({
    required this.dhikrType,
    required this.totalCount,
    required this.dateISO,
  });

  @HiveField(0)
  String dhikrType;

  @HiveField(1)
  int totalCount;

  @HiveField(2)
  String dateISO;
}
