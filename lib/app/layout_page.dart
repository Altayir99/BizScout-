import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/sessions/presentation/pages/sessions_page.dart';
import '../features/sessions/presentation/providers/sessions_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/providers/navigation_provider.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  final List<Widget> _pages = const [
    SearchPage(),
    ChatPage(),
    SessionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Scaffold(
      body: IndexedStack(index: nav.currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: nav.currentIndex,
          onTap: (i) {
            context.read<NavigationProvider>().goTo(i);
            // Auto-refresh sessions whenever the Verlauf tab is tapped
            if (i == 2) {
              context.read<SessionsProvider>().loadSessions();
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.search_rounded),
              ),
              label: 'Suche',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.chat_bubble_outline_rounded),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Icon(Icons.history_rounded),
              ),
              label: 'Verlauf',
            ),
          ],
        ),
      ),
    );
  }
}
