import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/adhkar_category_model.dart';
import '../data/models/dhikr_model.dart';
import '../data/models/tasbih_session_model.dart';
import '../data/models/tasbih_history_entry.dart';
import '../data/services/adhkar_service.dart';
import '../data/services/dhikr_counter_service.dart';
import '../data/services/tasbih_service.dart';

// ── Services ────────────────────────────────────────────────────────────────

final adhkarServiceProvider = Provider<AdhkarService>((_) => AdhkarService());

final dhikrCounterServiceProvider =
    Provider<DhikrCounterService>((_) => DhikrCounterService());

final tasbihServiceProvider = Provider<TasbihService>((_) => TasbihService());

// ── Data providers ──────────────────────────────────────────────────────────

final adhkarCategoriesProvider =
    FutureProvider<List<AdhkarCategoryModel>>((ref) {
  return ref.watch(adhkarServiceProvider).getCategories();
});

final dhikrListProvider =
    FutureProvider.family<List<DhikrModel>, String>((ref, categoryId) {
  return ref.watch(adhkarServiceProvider).getDhikrByCategory(categoryId);
});

// ── Dhikr counter state ──────────────────────────────────────────────────────

typedef DhikrKey = ({String categoryId, int index});

class DhikrCounterNotifier extends StateNotifier<int> {
  DhikrCounterNotifier(this._service, this._dhikr)
      : super(_service.getRemaining(_dhikr));

  final DhikrCounterService _service;
  final DhikrModel _dhikr;

  Future<void> decrement() async {
    if (state <= 0) return;
    await _service.decrement(_dhikr);
    state = _service.getRemaining(_dhikr);
  }

  bool get isComplete => state == 0;
}

final dhikrCounterProvider = StateNotifierProvider.family<DhikrCounterNotifier,
    int, DhikrKey>((ref, key) {
  final service = ref.watch(dhikrCounterServiceProvider);
  final dhikrListAsync =
      ref.watch(dhikrListProvider(key.categoryId));
  return dhikrListAsync.maybeWhen(
    data: (list) {
      if (key.index >= list.length) {
        final dummy = DhikrModel(
          index: key.index,
          categoryId: key.categoryId,
          text: '',
          repeat: 0,
        );
        return DhikrCounterNotifier(service, dummy);
      }
      return DhikrCounterNotifier(service, list[key.index]);
    },
    orElse: () {
      final dummy = DhikrModel(
        index: key.index,
        categoryId: key.categoryId,
        text: '',
        repeat: 0,
      );
      return DhikrCounterNotifier(service, dummy);
    },
  );
});

// ── Category completion ──────────────────────────────────────────────────────

final categoryCompletionProvider =
    Provider.family<bool, String>((ref, categoryId) {
  final dhikrAsync = ref.watch(dhikrListProvider(categoryId));
  return dhikrAsync.maybeWhen(
    data: (list) {
      if (list.isEmpty) return false;
      final service = ref.watch(dhikrCounterServiceProvider);
      return service.isCategoryComplete(list);
    },
    orElse: () => false,
  );
});

// ── Tasbih state ─────────────────────────────────────────────────────────────

const List<String> tasbihDhikrTypes = ['سبحان الله', 'الحمد لله', 'الله أكبر'];

class TasbihNotifier extends StateNotifier<TasbihSessionModel> {
  TasbihNotifier(this._service, String dhikrType)
      : super(_service.getOrCreateSession(dhikrType));

  final TasbihService _service;

  Future<bool> tap() async {
    final prev = state;
    state = await _service.tap(state);
    // Returns true if a round just completed
    return state.completedRounds > prev.completedRounds;
  }

  Future<void> reset() async {
    state = await _service.reset(state);
  }

  Future<void> logSession() async {
    await _service.logSession(state);
  }

  Future<void> switchDhikr(String dhikrType) async {
    state = _service.getOrCreateSession(dhikrType);
  }
}

final tasbihNotifierProvider =
    StateNotifierProvider<TasbihNotifier, TasbihSessionModel>((ref) {
  final service = ref.watch(tasbihServiceProvider);
  return TasbihNotifier(service, tasbihDhikrTypes.first);
});

final tasbihHistoryProvider = FutureProvider<List<TasbihHistoryEntry>>((ref) {
  return Future.value(ref.watch(tasbihServiceProvider).getHistory());
});

final tasbihSoundEnabledProvider = StateProvider<bool>((_) => true);
final tasbihVibrationEnabledProvider = StateProvider<bool>((_) => true);
