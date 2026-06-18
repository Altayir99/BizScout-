import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/widgets/insight_charts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../providers/search_provider.dart';
import '../../data/models/search_result.dart';
import '../../data/models/research_result.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _search(SearchProvider p) {
    _focus.unfocus();
    p.search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<SearchProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('BizScout',
            style: GoogleFonts.sourceSerif4(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          if (p.result != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 20),
              onPressed: () {
                _controller.clear();
                p.clear();
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 20),
            tooltip: 'Einstellungen',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: p.modes.map((m) {
                  final selected = m['key'] == p.selectedMode;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(m['label']!),
                      selected: selected,
                      onSelected: (_) => p.setMode(m['key']!),
                      selectedColor: AppColors.accent,
                      backgroundColor: AppColors.surfaceSecondary,
                      side: BorderSide(
                        color: selected ? AppColors.accent : AppColors.border,
                        width: 1,
                      ),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _search(p),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: p.modes
                            .firstWhere((m) => m['key'] == p.selectedMode)['hint'],
                        prefixIcon: Icon(Icons.search_rounded,
                            color: AppColors.textMuted, size: 20),
                        fillColor: AppColors.surface,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.border, width: 1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: p.isLoading ? null : () => _search(p),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: p.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_forward_rounded, size: 20),
                  ),
                ],
              ),
            ),
          ),
          // Recent searches (shown when idle, no results)
          if (p.result == null && !p.isLoading)
            _buildRecentChips(p),
          Expanded(child: _buildResults(p)),
        ],
      ),
    );
  }

  /// Recent searches shown as horizontal chips above results when idle
  Widget _buildRecentChips(SearchProvider p) {
    if (p.recentSearches.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Zuletzt gesucht',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8)),
              const Spacer(),
              GestureDetector(
                onTap: () => p.clearHistory(),
                child: Text('Löschen',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: p.recentSearches.map((q) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      _controller.text = q;
                      _search(p);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded,
                              size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 5),
                          Text(q,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchProvider p) {
    if (p.isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 16),
            Text('Suche läuft…',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }
    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.error_outline_rounded, size: 28, color: AppColors.error),
              ),
              const SizedBox(height: 16),
              Text(p.error!,
                  style: TextStyle(color: AppColors.error, fontSize: 14),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    if (p.result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.travel_explore_rounded, size: 36, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text('Marktintelligenz durchsuchen',
                style: GoogleFonts.sourceSerif4(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 8),
            Text('Wähle einen Modus und starte die Suche',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        // ── KI Analysis card ─────────────────────────────────────────────
        if (p.researchResult != null) ...[
          _AnalysisCard(result: p.researchResult!, query: _controller.text.trim()),
          const SizedBox(height: 16),
        ],

        // ── "Analysiere mit KI" button ────────────────────────────────────
        if (p.researchResult == null) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: p.isResearching ? null : () => p.analyze(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.accent.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: p.isResearching
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome_rounded, size: 18),
              label: Text(
                p.isResearching ? 'KI analysiert…' : 'Analysiere mit KI',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (p.researchError != null) ...[
          Text(p.researchError!,
              style: TextStyle(color: AppColors.error, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
        ],

        // ── "Im Chat besprechen" button ───────────────────────────────────
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final chatProvider = context.read<ChatProvider>();
              final nav = context.read<NavigationProvider>();
              await chatProvider.seedFromSearch(
                _controller.text.trim(),
                p.result!.answer,
              );
              nav.goToChat();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text(
              'Im Chat besprechen',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Search result card ────────────────────────────────────────────
        _ResultCard(result: p.result!, query: _controller.text.trim()),

        // ── Sources ───────────────────────────────────────────────────────
        if (p.result!.sources.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'QUELLEN',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ...p.result!.sources.asMap().entries
              .map((e) => _SourceTile(index: e.key + 1, url: e.value)),
        ],

        // ── Insight Charts ─────────────────────────────────────────────────
        const SizedBox(height: 20),
        SourceDomainChart(sources: p.result!.sources),
        if (p.modeCounts.isNotEmpty) ...[
          const SizedBox(height: 12),
          ModeUsagePieChart(modeCounts: p.modeCounts),
        ],
      ],
    );
  }
}

// ── Shared markdown style ────────────────────────────────────────────────────

MarkdownStyleSheet _mdStyle() => MarkdownStyleSheet(
      p: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.65),
      h1: GoogleFonts.sourceSerif4(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1.4),
      h2: GoogleFonts.sourceSerif4(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          height: 1.4),
      h3: TextStyle(
          color: AppColors.accent, fontSize: 15, fontWeight: FontWeight.w600),
      strong:
          TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
      em: TextStyle(
          color: AppColors.textSecondary, fontStyle: FontStyle.italic),
      listBullet: TextStyle(color: AppColors.accent, fontSize: 15),
      blockquote: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontStyle: FontStyle.italic),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: AppColors.accent, width: 3)),
        color: AppColors.accentSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
      code: TextStyle(
          color: AppColors.accent,
          backgroundColor: AppColors.surfaceSecondary,
          fontSize: 13),
    );

// ── Widgets ──────────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final SearchResult result;
  final String query;
  const _ResultCard({required this.result, required this.query});

  @override
  Widget build(BuildContext context) {
    final answer = result.answer;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.travel_explore_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('SUCHERGEBNIS',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0)),
              const Spacer(),
              // PDF export
              _IconAction(
                icon: Icons.picture_as_pdf_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  sl<ExportService>().shareSearchAsPdf(result, query);
                },
              ),
              const SizedBox(width: 4),
              // Copy button
              _IconAction(
                icon: Icons.copy_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: answer));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kopiert'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              // Share button
              _IconAction(
                icon: Icons.ios_share_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  Share.share(answer, subject: 'BizScout Suchergebnis');
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          MarkdownBody(
            data: answer,
            styleSheet: _mdStyle(),
            onTapLink: (_, href, __) async {
              if (href != null) {
                final uri = Uri.parse(href);
                if (await canLaunchUrl(uri)) launchUrl(uri);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  final ResearchResult result;
  final String query;
  const _AnalysisCard({required this.result, required this.query});

  @override
  Widget build(BuildContext context) {
    final analysis = result.aiAnalysis;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar — academic blockquote style
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.accentSubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.auto_awesome_rounded,
                            size: 15, color: AppColors.accent),
                      ),
                      const SizedBox(width: 8),
                      Text('KI-ANALYSE',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0)),
                      const Spacer(),
                      // PDF export
                      _IconAction(
                        icon: Icons.picture_as_pdf_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          sl<ExportService>().shareResearchAsPdf(result, query);
                        },
                      ),
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.copy_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Clipboard.setData(ClipboardData(text: analysis));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Analyse kopiert'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),
                      _IconAction(
                        icon: Icons.ios_share_rounded,
                        onTap: () {
                          HapticFeedback.lightImpact();
                          Share.share(analysis, subject: 'BizScout KI-Analyse');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 14),
                  MarkdownBody(
                    data: analysis,
                    styleSheet: _mdStyle(),
                    onTapLink: (_, href, __) async {
                      if (href != null) {
                        final uri = Uri.parse(href);
                        if (await canLaunchUrl(uri)) launchUrl(uri);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final int index;
  final String url;
  const _SourceTile({required this.index, required this.url});

  String _domain(String url) {
    try {
      return Uri.parse(url).host.replaceFirst('www.', '');
    } catch (_) {
      return url;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text('$index',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(_domain(url),
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Icon(Icons.open_in_new_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Subtle icon button used in card headers
class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconAction({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.transparent,
        ),
        child: Icon(icon, size: 16, color: AppColors.textMuted),
      ),
    );
  }
}
