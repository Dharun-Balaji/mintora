import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/data_provider.dart';
import '../providers/ai_provider.dart';
import '../models/goal.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  void _showAddGoalDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

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
                'Set New Goal',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Goal Title'),
              ),
              TextField(
                controller: targetController,
                decoration: const InputDecoration(labelText: 'Target Amount'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: currentController,
                decoration: const InputDecoration(
                  labelText: 'Current Saved Amount',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Deadline: '),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 365 * 5),
                        ),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                    child: Text(DateFormat.yMMMd().format(selectedDate)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final title = titleController.text;
                  final target = double.tryParse(targetController.text) ?? 0.0;
                  final current =
                      double.tryParse(currentController.text) ?? 0.0;

                  if (title.isNotEmpty && target > 0) {
                    final goal = Goal(
                      id: const Uuid().v4(),
                      title: title,
                      targetAmount: target,
                      currentAmount: current,
                      deadline: selectedDate,
                    );

                    final box = ref.read(goalsBoxProvider);
                    box.add(goal);

                    // Trigger AI Plan generation in background
                    final service = ref.read(geminiServiceProvider);
                    final transactions = ref.read(transactionsProvider);
                    if (service != null) {
                      final plan = await service.generateGoalPlan(
                        goal,
                        transactions,
                      );
                      // Update goal with plan
                      // Since Hive objects are mutable and live, we can just set it and save
                      // But better to use putAt or save()
                      goal.save(); // HiveObject method
                      // Actually we need to update the field.
                      // HiveObject doesn't have copyWith or direct field setters if not mutable in class?
                      // Wait, fields are final in my model. I need to replace the object.
                      final newGoal = Goal(
                        id: goal.id,
                        title: goal.title,
                        targetAmount: goal.targetAmount,
                        currentAmount: goal.currentAmount,
                        deadline: goal.deadline,
                        aiPlan: plan,
                      );
                      // Find index or key
                      final key = goal.key;
                      box.put(key, newGoal);
                    }

                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('Create Goal'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showGoalDetails(BuildContext context, Goal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Target: ${NumberFormat.simpleCurrency().format(goal.targetAmount)}',
              ),
              Text('Deadline: ${DateFormat.yMMMd().format(goal.deadline)}'),
              const Divider(),
              const Text(
                'AI Financial Plan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10),
              if (goal.aiPlan != null)
                MarkdownBody(data: goal.aiPlan!)
              else
                const Text(
                  'Generating plan... (Check back later or ensure API Key is set)',
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final currencyFormat = NumberFormat.simpleCurrency();

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Goals')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context, ref),
        child: const Icon(Icons.add),
      ),
      body: goals.isEmpty
          ? const Center(child: Text('No goals set'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final g = goals[index];
                final progress = (g.currentAmount / g.targetAmount).clamp(
                  0.0,
                  1.0,
                );
                return GestureDetector(
                  onTap: () => _showGoalDetails(context, g),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            g.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Text(
                            'Saved: ${currencyFormat.format(g.currentAmount)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Target: ${currencyFormat.format(g.targetAmount)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
