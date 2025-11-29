import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import 'data_provider.dart';

final geminiServiceProvider = Provider<GeminiService?>((ref) {
  final settingsAsync = ref.watch(appSettingsProvider);

  return settingsAsync.when(
    data: (settings) {
      if (settings.apiKey == null || settings.apiKey!.isEmpty) {
        return null;
      }
      return GeminiService(settings.apiKey!);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

final tipOfTheDayProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(geminiServiceProvider);
  final transactionsAsync = ref.watch(transactionsProvider);

  if (service == null) {
    return "Please enter your Gemini API Key in Settings to get AI tips.";
  }

  // Wait for transactions to load
  if (!transactionsAsync.hasValue) {
    return "Loading data...";
  }

  return service.generateTipOfTheDay(transactionsAsync.value!);
});
