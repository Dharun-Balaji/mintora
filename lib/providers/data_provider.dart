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

final transactionsProvider = Provider<List<Transaction>>((ref) {
  final box = ref.watch(transactionsBoxProvider);
  return box.values.toList();
});

final goalsProvider = Provider<List<Goal>>((ref) {
  final box = ref.watch(goalsBoxProvider);
  return box.values.toList();
});

final appSettingsProvider = Provider<AppSettings>((ref) {
  final box = ref.watch(settingsBoxProvider);
  if (box.isEmpty) {
    return AppSettings();
  }
  return box.getAt(0)!;
});
