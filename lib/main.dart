import 'package:ChatMcp/dao/init_db.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './logger.dart';
import './page/layout/layout.dart';
import './provider/provider_manager.dart';
import 'package:logging/logging.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de window_manager
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
  );

  // Configuration des options de la fenêtre
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  try {
    initializeLogger();
    await Future.wait([
      ProviderManager.init(),
      initDb(),
    ]);

    runApp(
      MultiProvider(
        providers: [
          ...ProviderManager.providers,
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.root.severe('Erreur principale: $e\nTrace de la pile:\n$stackTrace');
  }
}

// 在应用退出时清理资源
Future<void> cleanupResources() async {}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatMcp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: LayoutPage(),
        ),
      ),
    );
  }
}
