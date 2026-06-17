import 'package:flutter/material.dart';
import '../../data/models/search_result.dart';
import '../../data/models/research_result.dart';
import '../../data/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repo;
  SearchProvider(this._repo);

  SearchResult? result;
  ResearchResult? researchResult;
  bool isLoading = false;
  bool isResearching = false;
  String? error;
  String? researchError;
  String selectedMode = 'general';
  String _lastQuery = '';

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
    _lastQuery = query.trim();
    isLoading = true;
    error = null;
    researchResult = null;
    researchError = null;
    notifyListeners();
    try {
      result = await _repo.search(_lastQuery, selectedMode);
    } catch (e) {
      error = 'Fehler bei der Suche. Bitte versuche es erneut.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> analyze() async {
    if (_lastQuery.isEmpty || result == null) return;
    isResearching = true;
    researchError = null;
    notifyListeners();
    try {
      researchResult = await _repo.research(_lastQuery, selectedMode);
    } catch (e) {
      researchError = 'KI-Analyse fehlgeschlagen. Bitte versuche es erneut.';
    } finally {
      isResearching = false;
      notifyListeners();
    }
  }

  void clear() {
    result = null;
    researchResult = null;
    error = null;
    researchError = null;
    _lastQuery = '';
    notifyListeners();
  }
}
