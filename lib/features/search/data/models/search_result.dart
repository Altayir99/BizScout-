class SearchResult {
  final String answer;
  final List<String> sources;
  final String mode;

  const SearchResult({required this.answer, required this.sources, required this.mode});

  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    answer: json['answer'] as String,
    sources: List<String>.from(json['sources'] ?? []),
    mode: json['mode'] as String,
  );
}
