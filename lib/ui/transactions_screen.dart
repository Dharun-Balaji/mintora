import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/data_provider.dart';
import '../models/transaction.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  void _showAddTransactionDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Category (e.g. Food, Rent)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: selectedType == TransactionType.expense,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => selectedType = TransactionType.expense);
                    },
                    selectedColor: Colors.redAccent.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selectedType == TransactionType.expense
                          ? Colors.red
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: selectedType == TransactionType.income,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => selectedType = TransactionType.income);
                    },
                    selectedColor: Colors.greenAccent.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selectedType == TransactionType.income
                          ? Colors.green
                          : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final title = titleController.text;
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  final category = categoryController.text;

                  if (title.isNotEmpty && amount > 0) {
                    final transaction = Transaction(
                      id: const Uuid().v4(),
                      title: title,
                      amount: amount,
                      date: DateTime.now(),
                      type: selectedType,
                      category: category.isEmpty ? 'General' : category,
                    );

                    final box = ref.read(transactionsBoxProvider);
                    box.add(transaction);
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Transaction',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add New'),
      ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // Sort by date descending
          final sortedTransactions = List<Transaction>.from(transactions)
            ..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedTransactions.length,
            itemBuilder: (context, index) {
              final t = sortedTransactions[index];
              return Dismissible(
                key: Key(t.id),
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  t.delete();
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: t.type == TransactionType.income
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      child: Icon(
                        t.type == TransactionType.income
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: t.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(
                      t.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${DateFormat.yMMMd().format(t.date)} • ${t.category}',
                    ),
                    trailing: Text(
                      '${t.type == TransactionType.income ? '+' : '-'}${currencyFormat.format(t.amount)}',
                      style: TextStyle(
                        color: t.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX(),
              );
            },
          );
        },
      ),
    );
  }
}
