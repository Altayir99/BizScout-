import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../features/chat/data/models/chat_message.dart';
import '../../features/search/data/models/research_result.dart';
import '../../features/search/data/models/search_result.dart';

/// Generates branded BizScout PDF reports and shares them via iOS share sheet.
class ExportService {
  static const _teal = PdfColor.fromInt(0xFF1A5276);
  static const _ivory = PdfColor.fromInt(0xFFFAFAF7);
  static const _textDark = PdfColor.fromInt(0xFF2C2C2A);
  static const _textLight = PdfColor.fromInt(0xFF757570);
  static const _border = PdfColor.fromInt(0xFFE8E5E0);
  static const _accentSubtle = PdfColor.fromInt(0xFFEBF5F5);

  static final _dateFormat = DateFormat('dd.MM.yyyy HH:mm', 'de');

  // ─── Mode labels ──────────────────────────────────────────────────────────

  static const _modeLabels = {
    'restaurants': 'Gastronomie',
    'events': 'Events',
    'hotels': 'Hotels',
    'messen': 'Messen & Kongresse',
    'zeitarbeit': 'Zeitarbeit',
    'akquise': 'B2B Akquise',
    'markt': 'Marktanalyse',
    'general': 'Allgemein',
  };

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Export a Perplexity search result as PDF and open share sheet.
  Future<void> shareSearchAsPdf(SearchResult result, String query) async {
    final pdf = _buildSearchPdf(result, query);
    await _sharePdf(pdf, 'BizScout_Suche_${_safeFilename(query)}');
  }

  /// Export a full research analysis as PDF and open share sheet.
  Future<void> shareResearchAsPdf(ResearchResult result, String query) async {
    final pdf = _buildResearchPdf(result, query);
    await _sharePdf(pdf, 'BizScout_Analyse_${_safeFilename(query)}');
  }

  /// Export a chat conversation as PDF and open share sheet.
  Future<void> shareChatAsPdf(List<ChatMessage> messages, String? title) async {
    final pdf = _buildChatPdf(messages, title);
    await _sharePdf(pdf, 'BizScout_Chat_${_safeFilename(title ?? 'Unterhaltung')}');
  }

  // ─── PDF Builders ─────────────────────────────────────────────────────────

  pw.Document _buildSearchPdf(SearchResult result, String query) {
    final doc = pw.Document(
      title: 'BizScout Suchergebnis: $query',
      author: 'BizScout',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        header: (_) => _header('Suchergebnis'),
        footer: _footer,
        build: (context) => [
          _metaRow(query, result.mode),
          pw.SizedBox(height: 16),
          _sectionTitle('Ergebnis'),
          _contentBlock(result.answer),
          if (result.sources.isNotEmpty) ...[
            pw.SizedBox(height: 20),
            _sectionTitle('Quellen'),
            _sourcesList(result.sources),
          ],
        ],
      ),
    );

    return doc;
  }

  pw.Document _buildResearchPdf(ResearchResult result, String query) {
    final doc = pw.Document(
      title: 'BizScout Analyse: $query',
      author: 'BizScout',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        header: (_) => _header('KI-Analyse'),
        footer: _footer,
        build: (context) => [
          _metaRow(query, result.mode),
          pw.SizedBox(height: 16),

          // Perplexity summary
          _sectionTitle('Suchergebnis (Live-Daten)'),
          _contentBlock(result.searchSummary),
          pw.SizedBox(height: 20),

          // Claude analysis
          _accentBox('KI-Analyse (Claude)', result.aiAnalysis),
          pw.SizedBox(height: 20),

          // Sources
          if (result.sources.isNotEmpty) ...[
            _sectionTitle('Quellen'),
            _sourcesList(result.sources),
          ],
        ],
      ),
    );

    return doc;
  }

  pw.Document _buildChatPdf(List<ChatMessage> messages, String? title) {
    final doc = pw.Document(
      title: 'BizScout Chat: ${title ?? "Unterhaltung"}',
      author: 'BizScout',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(48),
        header: (_) => _header('Chat-Verlauf'),
        footer: _footer,
        build: (context) => [
          // Title bar
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: _accentSubtle,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(children: [
              pw.Text(
                title ?? 'Unterhaltung',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal,
                ),
              ),
              pw.Spacer(),
              pw.Text(
                '${messages.length} Nachrichten',
                style: pw.TextStyle(fontSize: 10, color: _textLight),
              ),
            ]),
          ),
          pw.SizedBox(height: 16),

          // Messages
          ...messages.map((msg) => _chatBubble(msg)),
        ],
      ),
    );

    return doc;
  }

  // ─── Reusable PDF Components ──────────────────────────────────────────────

  pw.Widget _header(String subtitle) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      padding: const pw.EdgeInsets.only(bottom: 12),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _teal, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BizScout',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: _teal,
                  )),
              pw.SizedBox(height: 2),
              pw.Text(subtitle,
                  style: pw.TextStyle(fontSize: 11, color: _textLight)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _dateFormat.format(DateTime.now()),
                style: pw.TextStyle(fontSize: 10, color: _textLight),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Business Intelligence',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: _teal,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _footer(pw.Context context) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: _border, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('BizScout — Vertraulich',
              style: pw.TextStyle(fontSize: 8, color: _textLight)),
          pw.Text('Seite ${context.pageNumber} / ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 8, color: _textLight)),
        ],
      ),
    );
  }

  pw.Widget _metaRow(String query, String mode) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: pw.BoxDecoration(
        color: _ivory,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _border, width: 0.5),
      ),
      child: pw.Row(children: [
        pw.Expanded(
          child: pw.RichText(
            text: pw.TextSpan(children: [
              pw.TextSpan(
                text: 'Suchanfrage: ',
                style: pw.TextStyle(fontSize: 11, color: _textLight),
              ),
              pw.TextSpan(
                text: query,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ]),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: pw.BoxDecoration(
            color: _teal,
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            _modeLabels[mode] ?? mode,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ]),
    );
  }

  pw.Widget _sectionTitle(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: _teal,
        ),
      ),
    );
  }

  pw.Widget _contentBlock(String content) {
    // Split markdown content into paragraphs
    final paragraphs = content.split('\n\n');
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: paragraphs.map((para) {
        final trimmed = para.trim();
        if (trimmed.isEmpty) return pw.SizedBox(height: 4);

        // Detect headings (## or ###)
        if (trimmed.startsWith('### ')) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
            child: pw.Text(
              trimmed.replaceFirst('### ', ''),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _teal,
              ),
            ),
          );
        }
        if (trimmed.startsWith('## ')) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12, bottom: 4),
            child: pw.Text(
              trimmed.replaceFirst('## ', ''),
              style: pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _textDark,
              ),
            ),
          );
        }

        // Detect bullet points
        if (trimmed.startsWith('- ') || trimmed.startsWith('* ')) {
          final lines = trimmed.split('\n');
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: lines.map((line) {
              final clean = line.replaceFirst(RegExp(r'^[-*]\s+'), '');
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 12, bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('•  ',
                        style: pw.TextStyle(fontSize: 11, color: _teal)),
                    pw.Expanded(
                      child: pw.Text(
                        _stripBold(clean),
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: _textDark,
                          lineSpacing: 4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }

        // Numbered lists
        if (RegExp(r'^\d+\.').hasMatch(trimmed)) {
          final lines = trimmed.split('\n');
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: lines.map((line) {
              return pw.Padding(
                padding: const pw.EdgeInsets.only(left: 8, bottom: 3),
                child: pw.Text(
                  _stripBold(line),
                  style: pw.TextStyle(
                    fontSize: 11,
                    color: _textDark,
                    lineSpacing: 4,
                  ),
                ),
              );
            }).toList(),
          );
        }

        // Regular paragraph
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Text(
            _stripBold(trimmed),
            style: pw.TextStyle(
              fontSize: 11,
              color: _textDark,
              lineSpacing: 5,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _accentBox(String title, String content) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: _accentSubtle,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: _teal, width: 1),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(children: [
            pw.Container(
              width: 4,
              height: 16,
              decoration: pw.BoxDecoration(
                color: _teal,
                borderRadius: pw.BorderRadius.circular(2),
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(title,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: _teal,
                )),
          ]),
          pw.SizedBox(height: 10),
          _contentBlock(content),
        ],
      ),
    );
  }

  pw.Widget _sourcesList(List<String> sources) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: sources.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final url = entry.value;
        // Truncate long URLs
        final display = url.length > 80 ? '${url.substring(0, 77)}...' : url;
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 3),
          child: pw.Text(
            '[$idx] $display',
            style: pw.TextStyle(
              fontSize: 9,
              color: _textLight,
            ),
          ),
        );
      }).toList(),
    );
  }

  pw.Widget _chatBubble(ChatMessage msg) {
    final isUser = msg.role == 'user';
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Role label
          pw.Container(
            width: 64,
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Text(
              isUser ? 'Du' : 'BizScout',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: isUser ? _textLight : _teal,
              ),
            ),
          ),
          // Message content
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: isUser ? _ivory : _accentSubtle,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(
                  color: isUser ? _border : _teal.shade(0.3),
                  width: 0.5,
                ),
              ),
              child: pw.Text(
                _stripBold(msg.content),
                style: pw.TextStyle(
                  fontSize: 10,
                  color: _textDark,
                  lineSpacing: 4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  /// Strip markdown bold markers for plain-text PDF rendering
  String _stripBold(String text) {
    return text.replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'$1').replaceAll('**', '');
  }

  /// Create a safe filename from user input
  String _safeFilename(String input) {
    final cleaned = input
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    return cleaned.substring(0, cleaned.length.clamp(0, 30));
  }

  /// Save PDF to temp dir and share via iOS share sheet
  Future<void> _sharePdf(pw.Document doc, String filenameBase) async {
    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$filenameBase.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf')],
      subject: filenameBase.replaceAll('_', ' '),
    );
  }
}
