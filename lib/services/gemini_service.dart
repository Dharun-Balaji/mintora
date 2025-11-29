import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/transaction.dart';
import '../models/goal.dart';

class GeminiService {
  final String apiKey;
  late final GenerativeModel _model;

  GeminiService(this.apiKey) {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  }

  Future<String> generateTipOfTheDay(List<Transaction> transactions) async {
    if (transactions.isEmpty) {
      return "Start tracking your expenses to get personalized tips!";
    }

    final prompt = '''
    Analyze these transactions and give a short, actionable financial tip (max 2 sentences).
    Transactions: \${transactions.map((t) => '\${t.title}: \${t.amount} (\${t.type})').join(', ')}
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Keep tracking your spending!";
    } catch (e) {
      return "Tip: Save more than you spend.";
    }
  }

  Future<String> generateGoalPlan(
    Goal goal,
    List<Transaction> transactions,
  ) async {
    final prompt = '''
    Create a detailed financial plan to reach this goal:
    Goal: \${goal.title}, Target: \${goal.targetAmount}, Current: \${goal.currentAmount}, Deadline: \${goal.deadline}
    
    Current Spending Context:
    \${transactions.take(20).map((t) => '\${t.title}: \${t.amount}').join(', ')}
    
    Provide a step-by-step plan with savings milestones and spending adjustments.
    Format as Markdown.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Could not generate plan.";
    } catch (e) {
      return "Error generating plan. Please check your API key.";
    }
  }

  Future<String> generateFullReport(
    List<Transaction> transactions,
    List<Goal> goals,
  ) async {
    final prompt = '''
    Generate a comprehensive financial report based on this data:
    
    Transactions (last 50):
    \${transactions.take(50).map((t) => '\${t.title}: \${t.amount} (\${t.category})').join(', ')}
    
    Goals:
    \${goals.map((g) => '\${g.title}: \${g.currentAmount}/\${g.targetAmount}').join(', ')}
    
    Please provide:
    1. Monthly Spending Analysis
    2. Category Breakdown
    3. Savings Rate Analysis
    4. Recommendations for reaching goals faster
    5. Future Predictions
    
    Format as Markdown with headers and bullet points.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "Could not generate report.";
    } catch (e) {
      return "Error generating report. Please check your API key.";
    }
  }

  Future<String> chat(String message, List<Transaction> contextData) async {
    final prompt = '''
    You are a helpful financial assistant.
    User context (last 10 transactions):
    \${contextData.take(10).map((t) => '\${t.title}: \${t.amount}').join(', ')}
    
    User: \$message
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? "I didn't understand that.";
    } catch (e) {
      return "I'm having trouble connecting. Please check your settings.";
    }
  }
}
