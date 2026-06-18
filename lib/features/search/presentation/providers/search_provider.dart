import 'package:flutter/material.dart';
import '../../data/models/search_result.dart';
import '../../data/models/research_result.dart';
import '../../data/repositories/search_repository.dart';
import '../../../../core/services/search_history_service.dart';
import '../../../../core/services/mode_usage_service.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repo;
  final _history = SearchHistoryService();
  final _modeUsage = ModeUsageService();

  SearchProvider(this._repo) {
    _loadHistory();
    _loadModeCounts();
  }

  SearchResult? result;
  ResearchResult? researchResult;
  bool isLoading = false;
  bool isResearching = false;
  String? error;
  String? researchError;
  String selectedMode = 'general';
  String _lastQuery = '';

  List<String> recentSearches = [];
  Map<String, int> modeCounts = {};

  final modes = [
    {'key': 'restaurants', 'label': '🍽️ Gastronomie',   'hint': 'z.B. Neue Restaurants Berlin 2025'},
    {'key': 'events',      'label': '📅 Events',          'hint': 'z.B. Großveranstaltungen Berlin Juni'},
    {'key': 'hotels',      'label': '🏨 Hotels',          'hint': 'z.B. Luxushotels Berlin Neueröffnungen'},
    {'key': 'messen',      'label': '🎪 Messen & Kongresse','hint': 'z.B. Messen Berlin 2025 Personalbedarf'},
    {'key': 'zeitarbeit',  'label': '👔 Zeitarbeit',      'hint': 'z.B. Zeitarbeitsmarkt Berlin Gastronomie'},
    {'key': 'akquise',     'label': '💼 B2B Akquise',     'hint': 'z.B. Catering Auftraggeber Berlin'},
    {'key': 'markt',       'label': '📊 Marktanalyse',    'hint': 'z.B. Gastronomie Trends Berlin 2025'},
    {'key': 'general',     'label': '🔍 Allgemein',       'hint': 'Beliebige Business-Anfrage...'},
  ];


  Future<void> _loadHistory() async {
    recentSearches = await _history.load();
    notifyListeners();
  }

  Future<void> _loadModeCounts() async {
    modeCounts = await _modeUsage.getCounts();
    notifyListeners();
  }

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
      await _history.add(_lastQuery);
      await _modeUsage.track(selectedMode);
      recentSearches = await _history.load();
      modeCounts = await _modeUsage.getCounts();
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

  Future<void> clearHistory() async {
    await _history.clear();
    recentSearches = [];
    notifyListeners();
  }
}

