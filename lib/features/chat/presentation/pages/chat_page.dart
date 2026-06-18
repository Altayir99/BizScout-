import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/export_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/chat_message.dart';
import '../providers/chat_provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send(ChatProvider p) {
    final text = _controller.text.trim();
    if (text.isEmpty || p.isTyping) return;
    _controller.clear();
    p.send(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ChatProvider>();

    // Auto-scroll on new messages
    if (p.messages.isNotEmpty || p.isTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.textPrimary,
                tooltip: 'Zurück',
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: Column(
          children: [
            Text('KI-Assistent',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            if (p.currentSessionId != null)
              Text('Aktive Sitzung',
                  style: TextStyle(fontSize: 11, color: AppColors.accent)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.border),
        ),
        actions: [
          if (p.messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 21),
              tooltip: 'Als PDF exportieren',
              onPressed: () {
                HapticFeedback.lightImpact();
                sl<ExportService>().shareChatAsPdf(
                  p.messages,
                  p.currentSessionId,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
            tooltip: 'Neuer Chat',
            onPressed: p.newChat,
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: p.messages.isEmpty && !p.isTyping
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: p.messages.length + (p.isTyping ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == p.messages.length) return _TypingBubble();
                      return _MessageBubble(message: p.messages[i]);
                    },
                  ),
          ),
          // Error
          if (p.error != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Text(p.error!,
                  style: TextStyle(color: AppColors.error, fontSize: 13)),
            ),
          // Input bar
          _InputBar(
              controller: _controller,
              focusNode: _focusNode,
              onSend: () => _send(p),
              isTyping: p.isTyping),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final p = context.read<ChatProvider>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accentSubtle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 32, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text('BizScout Assistent',
                style: GoogleFonts.sourceSerif4(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 8),
            Text(
              'Frag mich über Gastronomie, Events\noder Zeitarbeit in Berlin',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                '🍽️ Beste Restaurants Berlin',
                '📅 Events diese Woche',
                '👨‍🍳 Koch gesucht Berlin',
                '📊 Gastronomie Trends',
              ]
                  .map((hint) => GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          _controller.text = hint;
                          _send(p);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(hint,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  bool get isUser => message.role == 'user';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: message.content));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Kopiert'),
                      duration: Duration(seconds: 1)),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.bubbleUser : AppColors.bubbleAssistant,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 18),
                  ),
                  border: Border.all(
                    color: isUser
                        ? AppColors.accent.withOpacity(0.15)
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                child: isUser
                    ? SelectableText(
                        message.content,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.55,
                        ),
                      )
                    : MarkdownBody(
                        data: message.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              height: 1.6),
                          h1: GoogleFonts.sourceSerif4(
                              color: AppColors.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w700),
                          h2: GoogleFonts.sourceSerif4(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                          h3: TextStyle(
                              color: AppColors.accent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          strong: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700),
                          em: TextStyle(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic),
                          listBullet:
                              TextStyle(color: AppColors.accent, fontSize: 15),
                          code: TextStyle(
                              color: AppColors.accent,
                              backgroundColor: AppColors.surfaceSecondary,
                              fontSize: 13),
                          blockquoteDecoration: BoxDecoration(
                            border: Border(
                                left: BorderSide(
                                    color: AppColors.accent, width: 3)),
                            color: AppColors.accentSubtle,
                          ),
                        ),
                        onTapLink: (_, href, __) async {
                          if (href != null) {
                            final uri = Uri.parse(href);
                            if (await canLaunchUrl(uri)) launchUrl(uri);
                          }
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatefulWidget {
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 16, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bubbleAssistant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final delay = i / 3;
                  final opacity =
                      ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2 + opacity * 0.8),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool isTyping;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.isTyping,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              style: const TextStyle(
                  color: AppColors.textPrimary, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Nachricht eingeben...',
                fillColor: AppColors.surfaceSecondary,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.accent, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: isTyping ? null : onSend,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.accent.withOpacity(0.4),
              minimumSize: const Size(48, 48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: isTyping
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
