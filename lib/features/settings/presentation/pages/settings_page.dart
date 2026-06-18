import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../search/presentation/providers/search_provider.dart';
import '../../../sessions/presentation/providers/sessions_provider.dart';
import '../../../../core/services/api_client.dart';
import 'package:dio/dio.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _apiStatus = 'Prüfe…';
  Color _apiStatusColor = AppColors.textMuted;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _checkHealth();
  }

  Future<void> _checkHealth() async {
    setState(() {
      _checking = true;
      _apiStatus = 'Prüfe…';
      _apiStatusColor = AppColors.textMuted;
    });
    try {
      final dio = Dio();
      final resp = await dio
          .get('${ApiClient.baseUrl}/health')
          .timeout(const Duration(seconds: 5));
      if (resp.statusCode == 200) {
        setState(() {
          _apiStatus = 'Online ✓';
          _apiStatusColor = const Color(0xFF4CAF50);
        });
      } else {
        setState(() {
          _apiStatus = 'Fehler ${resp.statusCode}';
          _apiStatusColor = AppColors.error;
        });
      }
    } catch (_) {
      setState(() {
        _apiStatus = 'Nicht erreichbar';
        _apiStatusColor = AppColors.error;
      });
    } finally {
      setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── App Info ──────────────────────────────────────────────────────
          _SectionHeader(title: 'App'),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.travel_explore_rounded,
                label: 'BizScout',
                value: 'Version 1.0.0',
                iconColor: AppColors.accent,
              ),
              const Divider(color: AppColors.border, height: 1),
              _InfoRow(
                icon: Icons.business_rounded,
                label: 'Unternehmen',
                value: 'Gastronomie & Zeitarbeit Berlin',
                iconColor: AppColors.accent,
              ),
              const Divider(color: AppColors.border, height: 1),
              _InfoRow(
                icon: Icons.dns_rounded,
                label: 'API',
                value: 'api.facturo.it.com/bizscout',
                iconColor: AppColors.textMuted,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── API Status ────────────────────────────────────────────────────
          _SectionHeader(title: 'Server-Status'),
          _InfoCard(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: _apiStatusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _apiStatus.startsWith('Online')
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: _apiStatusColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Backend API',
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          Text(_apiStatus,
                              style: TextStyle(
                                  color: _apiStatusColor,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    if (_checking)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.accent),
                      )
                    else
                      GestureDetector(
                        onTap: _checkHealth,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Text('Prüfen',
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Daten verwalten ───────────────────────────────────────────────
          _SectionHeader(title: 'Daten'),
          _InfoCard(
            children: [
              _ActionRow(
                icon: Icons.history_rounded,
                label: 'Suchverlauf löschen',
                iconColor: AppColors.textMuted,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await context.read<SearchProvider>().clearHistory();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Suchverlauf gelöscht'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const Divider(color: AppColors.border, height: 1),
              _ActionRow(
                icon: Icons.delete_outline_rounded,
                label: 'Alle Sitzungen löschen',
                iconColor: Colors.redAccent,
                onTap: () => _confirmDeleteAll(context),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── KI-Modelle ────────────────────────────────────────────────────
          _SectionHeader(title: 'KI-Modelle'),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.auto_awesome_rounded,
                label: 'Chat & Analyse',
                value: 'Claude Sonnet 4.5',
                iconColor: AppColors.accent,
              ),
              const Divider(color: AppColors.border, height: 1),
              _InfoRow(
                icon: Icons.travel_explore_rounded,
                label: 'Live-Suche',
                value: 'Perplexity Sonar Pro',
                iconColor: AppColors.accent,
              ),
            ],
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              'BizScout • Private Intelligence\nBerlin 2025',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  height: 1.6),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Alle Sitzungen löschen?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            'Alle gespeicherten Gespräche werden unwiderruflich gelöscht.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final prov = context.read<SessionsProvider>();
              final sessions = List.from(prov.sessions);
              for (final s in sessions) {
                await prov.deleteSession(s.id);
              }
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alle Sitzungen gelöscht'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Löschen',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: iconColor == Colors.redAccent
                          ? Colors.redAccent
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
