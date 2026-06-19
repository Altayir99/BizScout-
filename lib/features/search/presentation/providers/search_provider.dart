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
    {'key': 'general',   'label': '🔍 Suche',         'hint': 'Alles suchen...'},
    {'key': 'markt',     'label': '📊 Marktanalyse',   'hint': 'z.B. KI Markt Deutschland 2025'},
    {'key': 'firmen',    'label': '🏢 Firmen',         'hint': 'z.B. Top Startups Berlin'},
    {'key': 'finanzen',  'label': '💰 Finanzen',       'hint': 'z.B. Umsatz Apple Q2 2025'},
    {'key': 'tech',      'label': '💻 Tech & Tools',   'hint': 'z.B. Beste CRM Software'},
    {'key': 'recht',     'label': '⚖️ Recht & Gesetz', 'hint': 'z.B. DSGVO Änderungen 2025'},
    {'key': 'trends',    'label': '📈 Trends',         'hint': 'z.B. E-Commerce Trends Europa'},
    {'key': 'akquise',   'label': '💼 B2B & Sales',    'hint': 'z.B. Lead-Generierung Strategien'},
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

