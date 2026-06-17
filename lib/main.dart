import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/sessions/presentation/providers/sessions_provider.dart';
import 'app/layout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  setupDependencies();
  runApp(const BizScoutApp());
}

class BizScoutApp extends StatelessWidget {
  const BizScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GetIt.I<SearchProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<ChatProvider>()),
        ChangeNotifierProvider(create: (_) => GetIt.I<SessionsProvider>()),
      ],
      child: MaterialApp(
        title: 'BizScout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: const LayoutPage(),
      ),
    );
  }
}
