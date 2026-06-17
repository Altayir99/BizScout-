class ResearchResult {
  final String searchSummary;
  final String aiAnalysis;
  final List<String> sources;
  final String mode;

  const ResearchResult({
    required this.searchSummary,
    required this.aiAnalysis,
    required this.sources,
    required this.mode,
  });

  factory ResearchResult.fromJson(Map<String, dynamic> json) => ResearchResult(
        searchSummary: json['search_summary'] as String,
        aiAnalysis: json['ai_analysis'] as String,
        sources: List<String>.from(json['sources'] ?? []),
        mode: json['mode'] as String,
      );
}
