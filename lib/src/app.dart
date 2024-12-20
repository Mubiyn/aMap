import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:map_test/src/features/map/presentation/ui/chat.dart';
import 'package:map_test/src/features/map/presentation/ui/favourites.dart';
import 'package:map_test/src/injection.dart';
import 'package:map_test/src/features/map/presentation/ui/map.dart';
import 'features/settings/settings_controller.dart';
import 'features/settings/settings_view.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsController,
      builder: (context, child) {
        return MaterialApp(
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: lightThemeData(),
          darkTheme: darkThemeData(),
          themeMode: locator<SettingsController>().themeMode,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: appRoutes,
        );
      },
    );
  }
}

ThemeData lightThemeData() {
  return ThemeData(useMaterial3: true).copyWith(
    brightness: Brightness.light,
    primaryColor: Colors.deepPurple.withOpacity(0.4),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.deepPurple.withOpacity(0.4),
      foregroundColor: Colors.white,
    ),
  );
}

ThemeData darkThemeData() {
  return ThemeData.dark(useMaterial3: true).copyWith(
    brightness: Brightness.dark,
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );
}

Route<dynamic> appRoutes(RouteSettings settings) {
  switch (settings.name) {
    case MapScreen.routeName:
      return MaterialPageRoute(builder: (_) => const MapScreen());
    case SettingsView.routeName:
      return MaterialPageRoute(builder: (_) => const SettingsView());
    case ChatScreen.routeName:
      return MaterialPageRoute(builder: (_) => const ChatScreen());
    case FavoritesScreen.routeName:
      return MaterialPageRoute(builder: (_) => const FavoritesScreen());
    default:
      return MaterialPageRoute(builder: (_) => const MapScreen());
  }
}
