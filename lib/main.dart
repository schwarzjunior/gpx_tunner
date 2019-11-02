import 'package:flutter/material.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:gpx_tunner/blocs/app_permissions_bloc.dart';
import 'package:gpx_tunner/ui/pages/app_start_page.dart';
import 'package:gpx_tunner/ui/pages/home_page.dart';

void main() {
  runApp(GpxTunnerApp());
}

class GpxTunnerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      blocs: [
        Bloc((i) => AppPermissionsBloc()),
      ],
      child: AppMainPage(),
    );
  }
}

class AppMainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPX Tunner',
      initialRoute: '/',
      routes: {
        '/': (context) => AppStartPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
