import 'package:shared_preferences/shared_preferences.dart';

/// Tracks how many times each search mode is used for analytics.
class ModeUsageService {
  static const _prefix = 'mode_usage_';

  static const _modes = [
    'restaurants', 'events', 'hotels', 'messen',
    'zeitarbeit', 'akquise', 'markt', 'general',
  ];

  /// Increment the usage count for a mode.
  Future<void> track(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt('$_prefix$mode') ?? 0;
    await prefs.setInt('$_prefix$mode', count + 1);
  }

  /// Get all mode usage counts.
  Future<Map<String, int>> getCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final counts = <String, int>{};
    for (final mode in _modes) {
      final count = prefs.getInt('$_prefix$mode') ?? 0;
      if (count > 0) counts[mode] = count;
    }
    return counts;
  }
}
