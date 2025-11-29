import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import 'data_provider.dart';

final geminiServiceProvider = Provider<GeminiService?>((ref) {
  final settings = ref.watch(appSettingsProvider);
  if (settings.apiKey == null || settings.apiKey!.isEmpty) {
    return null;
  }
  return GeminiService(settings.apiKey!);
});

final tipOfTheDayProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(geminiServiceProvider);
  final transactions = ref.watch(transactionsProvider);

  if (service == null) {
    return "Please enter your Gemini API Key in Settings to get AI tips.";
  }

  return service.generateTipOfTheDay(transactions);
});
