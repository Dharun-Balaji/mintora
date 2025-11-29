import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/data_provider.dart';
import '../providers/ai_provider.dart';

class AIReportScreen extends ConsumerStatefulWidget {
  const AIReportScreen({super.key});

  @override
  ConsumerState<AIReportScreen> createState() => _AIReportScreenState();
}

class _AIReportScreenState extends ConsumerState<AIReportScreen> {
  Future<String>? _reportFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReport();
    });
  }

  void _loadReport() {
    final service = ref.read(geminiServiceProvider);
    final transactionsAsync = ref.read(transactionsProvider);
    final goalsAsync = ref.read(goalsProvider);

    if (service == null) {
      setState(() {
        _reportFuture = Future.value(
          "Please set your API Key in Settings to generate reports.",
        );
      });
      return;
    }

    if (!transactionsAsync.hasValue || !goalsAsync.hasValue) {
      setState(() {
        _reportFuture = Future.value("Loading data... Please try again.");
      });
      return;
    }

    setState(() {
      _reportFuture = service.generateFullReport(
        transactionsAsync.value!,
        goalsAsync.value!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Financial Report')),
      body: _reportFuture == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<String>(
              future: _reportFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Analyzing your financial data...'),
                        Text(
                          'This may take a few seconds',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: MarkdownBody(
                    data: snapshot.data ?? 'No data',
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      p: const TextStyle(fontSize: 16, height: 1.5),
                      listBullet: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
