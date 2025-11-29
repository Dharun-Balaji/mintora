import 'package:hive/hive.dart';

part 'goal.g.dart';

@HiveType(typeId: 2)
class Goal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double currentAmount;

  @HiveField(4)
  final DateTime deadline;

  @HiveField(5)
  final String? aiPlan;

  Goal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.deadline,
    this.aiPlan,
  });
}
