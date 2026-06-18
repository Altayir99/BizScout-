import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/navigation_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/models/chat_session.dart';
import '../providers/sessions_provider.dart';

class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionsProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.accentSubtle,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verlauf',
                style: GoogleFonts.sourceSerif4(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const Text(
                'Gespeicherte Gespräche',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<SessionsProvider>(
            builder: (_, prov, __) => prov.loading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: AppColors.textMuted, size: 22),
                    onPressed: () =>
                        context.read<SessionsProvider>().loadSessions(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SessionsProvider>(
      builder: (context, prov, _) {
        if (prov.loading && prov.sessions.isEmpty) {
          return _buildLoadingState();
        }
        if (prov.error != null && prov.sessions.isEmpty) {
          return _buildErrorState(prov.error!);
        }
        if (prov.sessions.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSessionList(context, prov);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Lade Gespräche...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.surfaceSecondary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Noch keine Gespräche',
              style: GoogleFonts.sourceSerif4(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Starte ein Gespräch im Chat-Tab,\num es hier zu sehen.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  color: AppColors.error, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              'Verbindungsfehler',
              style: GoogleFonts.sourceSerif4(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList(BuildContext context, SessionsProvider prov) {
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surface,
      onRefresh: prov.loadSessions,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: prov.sessions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) =>
            _SessionCard(session: prov.sessions[i]),
      ),
    );
  }
}

// ─── Session Card ─────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final ChatSession session;
  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(Icons.delete_outline_rounded,
            color: AppColors.error, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Gespräch löschen?'),
            content: const Text(
                'Dieser Verlauf kann nicht wiederhergestellt werden.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Abbrechen',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Löschen',
                    style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) =>
          context.read<SessionsProvider>().deleteSession(session.id),
      child: GestureDetector(
        onTap: () => _openSession(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 12,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left: icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.chat_rounded,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              // Middle: title + metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(session.updatedAt),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                        if (session.messageCount > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.accentSubtle,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${session.messageCount} Msg',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _openSession(BuildContext context) {
    context.read<SessionsProvider>().loadSessionMessages(session.id);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SessionDetailSheet(session: session),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return 'Heute ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Gestern';
    if (diff.inDays < 7) return 'Vor ${diff.inDays} Tagen';
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}

// ─── Session Detail Bottom Sheet ──────────────────────────────────────────────

class _SessionDetailSheet extends StatelessWidget {
  final ChatSession session;
  const _SessionDetailSheet({required this.session});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      session.title,
                      style: GoogleFonts.sourceSerif4(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Resume in Chat button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      context.read<ChatProvider>().resumeSession(
                            session.id,
                            context
                                .read<SessionsProvider>()
                                .sessionMessages,
                          );
                      context.read<NavigationProvider>().goToChat();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Fortsetzen',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.border),
            // Messages
            Expanded(
              child: Consumer<SessionsProvider>(
                builder: (_, prov, __) {
                  if (prov.messagesLoading) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent, strokeWidth: 2));
                  }
                  if (prov.sessionMessages.isEmpty) {
                    return Center(
                        child: Text('Keine Nachrichten',
                            style: TextStyle(
                                color: AppColors.textSecondary)));
                  }
                  return ListView.builder(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: prov.sessionMessages.length,
                    itemBuilder: (ctx, i) {
                      final msg = prov.sessionMessages[i];
                      final isUser = msg.role == 'user';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: GestureDetector(
                            onLongPress: () {
                              HapticFeedback.mediumImpact();
                              Clipboard.setData(
                                  ClipboardData(text: msg.content));
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                  content: Text('Nachricht kopiert'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(ctx).size.width *
                                      0.82),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? AppColors.accentSubtle
                                    : AppColors.surfaceSecondary,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(14),
                                  topRight: const Radius.circular(14),
                                  bottomLeft:
                                      Radius.circular(isUser ? 14 : 4),
                                  bottomRight:
                                      Radius.circular(isUser ? 4 : 14),
                                ),
                                border: isUser
                                    ? Border.all(
                                        color: AppColors.accent
                                            .withOpacity(0.15))
                                    : null,
                              ),
                              child: isUser
                                  ? Text(
                                      msg.content,
                                      style: const TextStyle(
                                        color: AppColors.accent,
                                        fontSize: 14,
                                        height: 1.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  : MarkdownBody(
                                      data: msg.content,
                                      styleSheet: MarkdownStyleSheet(
                                        p: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            height: 1.55),
                                        strong: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700),
                                        h3: TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        listBullet: TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 14),
                                        code: TextStyle(
                                            color: AppColors.accent,
                                            backgroundColor:
                                                AppColors.surfaceSecondary,
                                            fontSize: 12),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
