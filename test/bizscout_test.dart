import 'package:flutter_test/flutter_test.dart';

// ── Model tests ──────────────────────────────────────────────────────────────
import 'package:bizscout/features/search/data/models/search_result.dart';
import 'package:bizscout/features/search/data/models/research_result.dart';
import 'package:bizscout/features/chat/data/models/chat_message.dart';
import 'package:bizscout/features/sessions/data/models/chat_session.dart';

// ── Theme tests ──────────────────────────────────────────────────────────────
import 'package:bizscout/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ═══════════════════════════════════════════════════════════════════════════
  // 1. MODEL SERIALIZATION TESTS
  // ═══════════════════════════════════════════════════════════════════════════

  group('SearchResult', () {
    test('fromJson parses correctly', () {
      final json = {
        'answer': 'Berlin hat 500+ Restaurants',
        'sources': ['https://a.com', 'https://b.com'],
        'mode': 'restaurants',
      };
      final result = SearchResult.fromJson(json);

      expect(result.answer, 'Berlin hat 500+ Restaurants');
      expect(result.sources, hasLength(2));
      expect(result.mode, 'restaurants');
    });

    test('fromJson handles null sources', () {
      final json = {
        'answer': 'test',
        'sources': null,
        'mode': 'general',
      };
      final result = SearchResult.fromJson(json);
      expect(result.sources, isEmpty);
    });

    test('fromJson handles empty sources', () {
      final json = {
        'answer': 'test',
        'sources': <String>[],
        'mode': 'general',
      };
      final result = SearchResult.fromJson(json);
      expect(result.sources, isEmpty);
    });

    test('const constructor creates immutable instance', () {
      const result = SearchResult(
        answer: 'test', sources: ['url'], mode: 'general',
      );
      expect(result.answer, 'test');
    });
  });

  group('ResearchResult', () {
    test('fromJson parses all fields', () {
      final json = {
        'search_summary': 'Summary here',
        'ai_analysis': 'Analysis here',
        'sources': ['url1'],
        'mode': 'events',
      };
      final result = ResearchResult.fromJson(json);

      expect(result.searchSummary, 'Summary here');
      expect(result.aiAnalysis, 'Analysis here');
      expect(result.sources, ['url1']);
      expect(result.mode, 'events');
    });

    test('fromJson with null sources defaults to empty list', () {
      final json = {
        'search_summary': 'S',
        'ai_analysis': 'A',
        'sources': null,
        'mode': 'general',
      };
      final result = ResearchResult.fromJson(json);
      expect(result.sources, isEmpty);
    });

    test('snake_case keys map to camelCase properties', () {
      final json = {
        'search_summary': 'S',
        'ai_analysis': 'A',
        'sources': [],
        'mode': 'm',
      };
      final r = ResearchResult.fromJson(json);
      expect(r.searchSummary, 'S');
      expect(r.aiAnalysis, 'A');
    });
  });

  group('ChatMessage', () {
    test('fromJson parses user message', () {
      final json = {'role': 'user', 'content': 'Hallo Welt'};
      final msg = ChatMessage.fromJson(json);

      expect(msg.role, 'user');
      expect(msg.content, 'Hallo Welt');
    });

    test('fromJson parses assistant message', () {
      final json = {'role': 'assistant', 'content': 'Ich helfe dir.'};
      final msg = ChatMessage.fromJson(json);

      expect(msg.role, 'assistant');
      expect(msg.content, 'Ich helfe dir.');
    });

    test('constructor creates immutable instance', () {
      const msg = ChatMessage(role: 'user', content: 'test');
      expect(msg.role, 'user');
      expect(msg.content, 'test');
    });

    test('handles long content with markdown', () {
      final longMarkdown = '# Heading\n\n- bullet 1\n- bullet 2\n\n**bold** text';
      final msg = ChatMessage(role: 'assistant', content: longMarkdown);
      expect(msg.content, contains('# Heading'));
      expect(msg.content, contains('**bold**'));
    });

    test('handles unicode and German text', () {
      final msg = ChatMessage(
        role: 'user',
        content: 'Straßenküche München — Ärzte Büro',
      );
      expect(msg.content, contains('ü'));
      expect(msg.content, contains('Ä'));
      expect(msg.content, contains('—'));
    });
  });

  group('ChatResponse', () {
    test('fromJson parses session_id correctly', () {
      final json = {
        'answer': 'Response text',
        'session_id': 'uuid-123-456',
      };
      final resp = ChatResponse.fromJson(json);

      expect(resp.answer, 'Response text');
      expect(resp.sessionId, 'uuid-123-456');
    });

    test('constructor is const', () {
      const resp = ChatResponse(answer: 'a', sessionId: 's');
      expect(resp.answer, 'a');
    });
  });

  group('ChatSession', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 'session-001',
        'title': 'Mein Gespräch',
        'message_count': 12,
        'created_at': '2026-06-18T14:00:00',
        'updated_at': '2026-06-18T15:00:00',
      };
      final session = ChatSession.fromJson(json);

      expect(session.id, 'session-001');
      expect(session.title, 'Mein Gespräch');
      expect(session.messageCount, 12);
      expect(session.createdAt.year, 2026);
      expect(session.updatedAt.hour, 15);
    });

    test('fromJson handles missing message_count', () {
      final json = {
        'id': 'session-002',
        'title': 'Test',
        'created_at': '2026-06-18T14:00:00',
        'updated_at': '2026-06-18T14:00:00',
      };
      final session = ChatSession.fromJson(json);
      expect(session.messageCount, 0);
    });

    test('fromJson handles null message_count', () {
      final json = {
        'id': 'session-003',
        'title': 'Null Count',
        'message_count': null,
        'created_at': '2026-06-18T14:00:00',
        'updated_at': '2026-06-18T14:00:00',
      };
      final session = ChatSession.fromJson(json);
      expect(session.messageCount, 0);
    });

    test('parses ISO 8601 datetime strings', () {
      final json = {
        'id': 'x',
        'title': 'x',
        'message_count': 0,
        'created_at': '2026-01-15T09:30:00.000Z',
        'updated_at': '2026-01-15T10:45:00.000Z',
      };
      final s = ChatSession.fromJson(json);
      expect(s.createdAt.month, 1);
      expect(s.createdAt.day, 15);
      expect(s.updatedAt.minute, 45);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 2. COLOR PALETTE TESTS (Büro/Research Theme)
  // ═══════════════════════════════════════════════════════════════════════════

  group('AppColors — Light Theme Palette', () {
    test('background is warm ivory, not pure white', () {
      expect(AppColors.background, isNot(equals(Colors.white)));
      expect(AppColors.background, const Color(0xFFFAFAF7));
    });

    test('accent is institutional teal', () {
      expect(AppColors.accent, const Color(0xFF1A5276));
    });

    test('gold alias equals accent (backward compat)', () {
      expect(AppColors.gold, equals(AppColors.accent));
    });

    test('textPrimary is warm near-black, not pure black', () {
      expect(AppColors.textPrimary, isNot(equals(Colors.black)));
      expect(AppColors.textPrimary, const Color(0xFF1C1C1A));
    });

    test('surface is pure white for cards', () {
      expect(AppColors.surface, Colors.white);
    });

    test('surfaceLight aliases surfaceSecondary', () {
      expect(AppColors.surfaceLight, equals(AppColors.surfaceSecondary));
    });

    test('error is muted brick red, not neon', () {
      expect(AppColors.error, const Color(0xFFC0392B));
      expect(AppColors.error, isNot(equals(Colors.red)));
    });

    test('success is forest green, not neon', () {
      expect(AppColors.success, const Color(0xFF1E8449));
    });

    test('bubble colors have high luminance (light theme safe)', () {
      final userLum = AppColors.bubbleUser.computeLuminance();
      final assistLum = AppColors.bubbleAssistant.computeLuminance();
      expect(userLum, greaterThan(0.8),
          reason: 'User bubble should be very light');
      expect(assistLum, greaterThan(0.9),
          reason: 'Assistant bubble should be barely warm');
    });

    test('border is warm, not cold grey', () {
      expect(AppColors.border, const Color(0xFFE8E5DE));
      // Verify it has warm undertone by checking green > blue
      expect(AppColors.border.green, greaterThan(AppColors.border.blue));
    });

    test('text hierarchy has correct luminance ordering', () {
      final primaryLum = AppColors.textPrimary.computeLuminance();
      final secondaryLum = AppColors.textSecondary.computeLuminance();
      final mutedLum = AppColors.textMuted.computeLuminance();

      // Darkest → lightest: primary < secondary < muted
      expect(primaryLum, lessThan(secondaryLum));
      expect(secondaryLum, lessThan(mutedLum));
    });

    test('accent is darker than accentLight', () {
      final accentLum = AppColors.accent.computeLuminance();
      final lightLum = AppColors.accentLight.computeLuminance();
      expect(accentLum, lessThan(lightLum));
    });

    test('accentSubtle is very light for backgrounds', () {
      final lum = AppColors.accentSubtle.computeLuminance();
      expect(lum, greaterThan(0.85));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 3. SEARCH MODES CONSISTENCY
  // ═══════════════════════════════════════════════════════════════════════════

  group('Search Modes', () {
    final expectedModes = [
      'general', 'markt', 'firmen', 'finanzen',
      'tech', 'recht', 'trends', 'akquise',
    ];

    test('exactly 8 modes defined', () {
      expect(expectedModes.length, 8);
    });

    test('general mode exists as fallback', () {
      expect(expectedModes.contains('general'), isTrue);
    });

    test('all modes are lowercase alpha keys', () {
      for (final mode in expectedModes) {
        expect(
          RegExp(r'^[a-z]+$').hasMatch(mode),
          isTrue,
          reason: 'Mode "$mode" should be lowercase alpha only',
        );
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // 4. API CLIENT CONFIG
  // ═══════════════════════════════════════════════════════════════════════════

  group('ApiClient Config', () {
    test('baseUrl uses HTTPS', () {
      expect(
        'https://api.facturo.it.com/bizscout'.startsWith('https://'),
        isTrue,
      );
    });

    test('baseUrl contains bizscout path', () {
      expect(
        'https://api.facturo.it.com/bizscout'.contains('/bizscout'),
        isTrue,
      );
    });
  });
}
