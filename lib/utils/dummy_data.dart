import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/goal.dart';

class DummyDataGenerator {
  static void inject(Box<Transaction> transactionBox, Box<Goal> goalBox) {
    if (transactionBox.isNotEmpty) return;

    final transactions = [
      Transaction(
        id: const Uuid().v4(),
        title: 'Salary',
        amount: 5000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        type: TransactionType.income,
        category: 'Salary',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Rent',
        amount: 1200,
        date: DateTime.now().subtract(const Duration(days: 1)),
        type: TransactionType.expense,
        category: 'Housing',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Groceries',
        amount: 150,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: 'Food',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Netflix',
        amount: 15,
        date: DateTime.now(),
        type: TransactionType.expense,
        category: 'Entertainment',
      ),
      Transaction(
        id: const Uuid().v4(),
        title: 'Freelance Project',
        amount: 800,
        date: DateTime.now().subtract(const Duration(days: 5)),
        type: TransactionType.income,
        category: 'Freelance',
      ),
    ];

    transactionBox.addAll(transactions);

    final goals = [
      Goal(
        id: const Uuid().v4(),
        title: 'New Laptop',
        targetAmount: 2000,
        currentAmount: 500,
        deadline: DateTime.now().add(const Duration(days: 90)),
      ),
      Goal(
        id: const Uuid().v4(),
        title: 'Vacation',
        targetAmount: 3000,
        currentAmount: 1000,
        deadline: DateTime.now().add(const Duration(days: 180)),
      ),
    ];

    goalBox.addAll(goals);
  }
}
