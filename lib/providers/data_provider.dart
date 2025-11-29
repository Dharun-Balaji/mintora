import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/local_database.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/settings.dart';

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

final transactionsBoxProvider = Provider<Box<Transaction>>((ref) {
  return ref.watch(localDatabaseProvider).transactionsBox;
});

final goalsBoxProvider = Provider<Box<Goal>>((ref) {
  return ref.watch(localDatabaseProvider).goalsBox;
});

final settingsBoxProvider = Provider<Box<AppSettings>>((ref) {
  return ref.watch(localDatabaseProvider).settingsBox;
});

// Reactive Transactions Provider
final transactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final box = ref.watch(transactionsBoxProvider);
  // Emit current values immediately
  // We need to yield the initial state, but StreamProvider does that if we return a Stream that starts with value?
  // Hive watch() returns a stream of BoxEvent. We need to map that to the list of values.

  return box
      .watch()
      .map((event) {
        return box.values.toList();
      })
      .startWith(box.values.toList());
});

// Reactive Goals Provider
final goalsProvider = StreamProvider<List<Goal>>((ref) {
  final box = ref.watch(goalsBoxProvider);
  return box
      .watch()
      .map((event) {
        return box.values.toList();
      })
      .startWith(box.values.toList());
});

// Reactive Settings Provider
final appSettingsProvider = StreamProvider<AppSettings>((ref) {
  final box = ref.watch(settingsBoxProvider);
  return box
      .watch()
      .map((event) {
        if (box.isEmpty) return AppSettings();
        return box.getAt(0)!;
      })
      .startWith(box.isEmpty ? AppSettings() : box.getAt(0)!);
});

// Extension to emit initial value
extension StreamStartWith<T> on Stream<T> {
  Stream<T> startWith(T initial) async* {
    yield initial;
    yield* this;
  }
}
