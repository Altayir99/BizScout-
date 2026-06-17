import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/search_provider.dart';

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
      appBar: AppBar(
        title: const Text('BizScout Suche'),
        actions: [
          if (p.result != null)
            IconButton(icon: const Icon(Icons.clear), onPressed: () {
              _controller.clear();
              p.clear();
            }),
        ],
      ),
      body: Column(
        children: [
          // Mode selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                      backgroundColor: AppColors.surfaceLight,
                      labelStyle: TextStyle(
                        color: selected ? Colors.black : AppColors.textSecondary,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(p),
                    decoration: InputDecoration(
                      hintText: p.modes.firstWhere((m) => m['key'] == p.selectedMode)['hint'],
                      prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: p.isLoading ? null : () => _search(p),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: p.isLoading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Icon(Icons.arrow_forward_rounded),
                ),
              ],
            ),
          ),
          // Results
          Expanded(child: _buildResults(p)),
        ],
      ),
    );
  }

  Widget _buildResults(SearchProvider p) {
    if (p.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (p.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(p.error!, style: TextStyle(color: AppColors.error), textAlign: TextAlign.center),
        ),
      );
    }
    if (p.result == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.travel_explore_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Wähle einen Modus und suche', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Answer card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SelectableText(
              p.result!.answer,
              style: const TextStyle(fontSize: 15, height: 1.6),
            ),
          ),
        ),
        // Sources
        if (p.result!.sources.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Quellen', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...p.result!.sources.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${e.key + 1}. ', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                Expanded(child: Text(e.value, style: TextStyle(color: AppColors.textSecondary, fontSize: 12))),
              ],
            ),
          )),
        ],
      ],
    );
  }
}
