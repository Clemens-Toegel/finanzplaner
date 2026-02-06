import 'package:flutter/material.dart';

import 'gen/app_localizations.dart';
import 'screens/purchase_home_page.dart';
import 'theme/app_theme.dart';

class PurchaseTrackerApp extends StatelessWidget {
  const PurchaseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      themeMode: ThemeMode.system,
      theme: AppTheme.buildLightTheme(),
      darkTheme: AppTheme.buildDarkTheme(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const PurchaseHomePage(),
    );
  }
}
