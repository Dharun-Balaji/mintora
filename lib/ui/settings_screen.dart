import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/data_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider);
    _apiKeyController = TextEditingController(text: settings.apiKey);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _saveApiKey() {
    final settings = ref.read(appSettingsProvider);
    final box = ref.read(settingsBoxProvider);
    final newSettings = settings.copyWith(apiKey: _apiKeyController.text);

    if (box.isEmpty) {
      box.add(newSettings);
    } else {
      box.putAt(0, newSettings);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('API Key Saved')));
  }

  void _updateTheme(String mode) {
    final settings = ref.read(appSettingsProvider);
    final box = ref.read(settingsBoxProvider);
    final newSettings = settings.copyWith(themeMode: mode);

    if (box.isEmpty) {
      box.add(newSettings);
    } else {
      box.putAt(0, newSettings);
    }
    // Riverpod will automatically rebuild listeners
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gemini API Key',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Required for AI features'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter your API Key',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveApiKey,
                    child: const Text('Save Key'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'light', label: Text('Light')),
                      ButtonSegment(value: 'dark', label: Text('Dark')),
                      ButtonSegment(value: 'amoled', label: Text('AMOLED')),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (Set<String> newSelection) {
                      _updateTheme(newSelection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
