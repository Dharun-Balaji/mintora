import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
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
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Transaction',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (e.g. Food, Rent)',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Type: '),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Expense'),
                    selected: selectedType == TransactionType.expense,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => selectedType = TransactionType.expense);
                    },
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('Income'),
                    selected: selectedType == TransactionType.income,
                    onSelected: (selected) {
                      if (selected)
                        setState(() => selectedType = TransactionType.income);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                child: const Text('Add Transaction'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final t = transactions[index];
                return Dismissible(
                  key: Key(t.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    t.delete(); // HiveObject method
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: t.type == TransactionType.income
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      child: Icon(
                        t.type == TransactionType.income
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        color: t.type == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    title: Text(t.title),
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
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
