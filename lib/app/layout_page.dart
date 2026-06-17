import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/search/presentation/pages/search_page.dart';
import '../features/chat/presentation/pages/chat_page.dart';
import '../features/sessions/presentation/pages/sessions_page.dart';
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
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: nav.currentIndex,
          onTap: (i) => context.read<NavigationProvider>().goTo(i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              label: 'Suche',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Verlauf',
            ),
          ],
        ),
      ),
    );
  }
}
