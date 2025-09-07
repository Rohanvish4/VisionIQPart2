import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../provider/video_provider.dart';
import '../model/gemini_model.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final videoProvider = Get.find<VideoProvider>();
    final GeminiModel model = videoProvider.geminiModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Result')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            Text('Environment Detected: ${model.environmentType} (Confidence: ${model.confidenceSummary.toStringAsFixed(2)})',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Infrastructure:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...model.infrastructure.map((i) => ListTile(
              title: Text(i.itemName),
              trailing: Text('x${i.quantity} (${i.confidenceScore.toStringAsFixed(2)})'),
            )),
            const SizedBox(height: 6),
            const Text('Inventory:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...model.inventory.map((i) => ListTile(
              title: Text(i.itemName),
              trailing: Text('x${i.quantity} (${i.confidenceScore.toStringAsFixed(2)})'),
            )),
            const SizedBox(height: 6),
            const Text('Detected Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...model.detectedItems.map((i) => ListTile(
              title: Text(i.itemName),
              trailing: Text('x${i.quantity} (${i.confidenceScore.toStringAsFixed(2)})'),
            )),
            const SizedBox(height: 12),
            Text('Total Items Count: ${model.totalItemsCount}'),
            const SizedBox(height: 6),
            Text('Location Context: ${model.locationContext}'),
            const SizedBox(height: 6),
            Text('Use Case: ${model.useCase}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final risk = model.environmentType.toLowerCase().contains('shop') &&
                    model.locationContext.toLowerCase().contains('home');
                final decision = risk ? 'Review Needed' : 'Pass';
                showDialog(context: context, builder: (_) => AlertDialog(
                  title: const Text('Decision Suggestion'),
                  content: Text('Suggested decision: $decision'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
                  ],
                ));
              },
              child: const Text('Get Decision Suggestion'),
            )
          ],
        ),
      ),
    );
  }
}
