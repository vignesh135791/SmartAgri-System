import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_recommendation.dart';
import '../services/api_client.dart';

class RecommendationCard extends StatefulWidget {
  const RecommendationCard({super.key});

  @override
  State<RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<RecommendationCard> {
  late Future<AiRecommendation> _recommendation;

  @override
  void initState() {
    super.initState();
    _recommendation = context.read<ApiClient>().getLatestRecommendation();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AiRecommendation>(
      future: _recommendation,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text(
            'AI suggestions are unavailable. Check the backend connection.',
          );
        }

        final recommendation = snapshot.data!;
        if (recommendation.recommendations.isEmpty) {
          return _card(
            title: 'AI productivity assistant',
            children: [Text(recommendation.summary)],
          );
        }

        return _card(
          title: 'AI productivity suggestions',
          children: [
            Text(recommendation.summary),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(recommendation.confidence * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...recommendation.recommendations.map(
              (crop) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(crop.crop),
                subtitle: Text(crop.reasons.join('; ')),
                trailing: Text('${(crop.confidence * 100).toStringAsFixed(0)}%'),
              ),
            ),
            ...recommendation.productivityInsights.map(
              (insight) => Text('• $insight'),
            ),
          ],
        );
      },
    );
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
