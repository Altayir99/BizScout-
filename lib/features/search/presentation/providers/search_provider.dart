import 'package:flutter/material.dart';
import '../../data/models/search_result.dart';
import '../../data/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repo;
  SearchProvider(this._repo);

  SearchResult? result;
  bool isLoading = false;
  String? error;
  String selectedMode = 'general';

  final modes = [
    {'key': 'restaurants', 'label': '🍽️ Restaurants', 'hint': 'z.B. Beste Restaurants Berlin 2025'},
    {'key': 'events', 'label': '📅 Events', 'hint': 'z.B. Großveranstaltungen Berlin Juni'},
    {'key': 'general', 'label': '🔍 Allgemein', 'hint': 'z.B. Gastronomie Trends Berlin'},
  ];

  void setMode(String mode) {
    selectedMode = mode;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      result = await _repo.search(query.trim(), selectedMode);
    } catch (e) {
      error = 'Fehler bei der Suche. Bitte versuche es erneut.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    result = null;
    error = null;
    notifyListeners();
  }
}
