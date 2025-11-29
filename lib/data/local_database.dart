import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/goal.dart';
import '../models/settings.dart';

class LocalDatabase {
  static const String transactionsBoxName = 'transactions';
  static const String goalsBoxName = 'goals';
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(GoalAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    await Hive.openBox<Transaction>(transactionsBoxName);
    await Hive.openBox<Goal>(goalsBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);
  }

  Box<Transaction> get transactionsBox =>
      Hive.box<Transaction>(transactionsBoxName);
  Box<Goal> get goalsBox => Hive.box<Goal>(goalsBoxName);
  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);
}
