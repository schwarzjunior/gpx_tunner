import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dynamic_theme_changer/dynamic_theme_changer.dart';
import 'package:gpx_tunner/blocs/app_permissions_bloc.dart';
import 'package:gpx_tunner/app_themes.dart';
import 'package:gpx_tunner/ui/pages/app_start_page.dart';
import 'package:gpx_tunner/ui/pages/home_page.dart';
import 'package:gpx_tunner/ui/pages/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AppThemes.initThemes().whenComplete(() => runApp(GpxTunnerApp()));
}

class GpxTunnerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => ThemeBloc()),
        Bloc((i) => AppPermissionsBloc()),
      ],
      child: AppMainPage(),
    );
  }
}

class AppMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.getBloc<ThemeBloc>();

    return StreamBuilder<ThemeData>(
      stream: themeBloc.outThemeData,
      initialData: ThemeStore.instance.currentThemeData,
      builder: (context, snapshot) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'GPX Tunner',
          theme: snapshot.data,
          initialRoute: '/',
          routes: {
            '/': (context) => AppStartPage(),
            '/home': (context) => HomePage(),
            '/settings': (context) => SettingsPage(),
          },
        );
      },
    );
  }
}
