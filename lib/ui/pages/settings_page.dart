import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:dynamic_theme_changer/dynamic_theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:gpx_tunner/ui/widgets/labeled_switch.dart';

class SettingsPage extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeBloc = BlocProvider.getBloc<ThemeBloc>();

    return WillPopScope(
      onWillPop: () => _onWillPop(themeBloc),
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(title: const Text('Configurações')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              StreamBuilder<ThemeProps>(
                stream: themeBloc.outThemeMode,
                initialData: themeBloc.selectedTheme,
                builder: (context, snapshot) {
                  return LabeledSwitch(
                    padding: const EdgeInsets.all(0),
                    label: 'Modo noturno',
                    value: snapshot.data.inDarkMode,
                    onChanged: !themeBloc.selectedTheme.hasBothModes
                        ? null
                        : themeBloc.changeThemeMode,
                  );
                },
              ),
              _divider,
              _saveButton(themeBloc),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop(ThemeBloc themeBloc) async {
    if (themeBloc.selectedTheme != themeBloc.lastSavedTheme) {
      themeBloc.restoreLastSavedTheme();
      return await Future.delayed(const Duration(milliseconds: 1000)).then((_) => true);
    }
    return Future<bool>.value(true);
  }

  Widget _saveButton(ThemeBloc themeBloc) {
    return RaisedButton(
      child: const Text('Salvar preferências'),
      onPressed: () {
        themeBloc.saveTheme();

        _scaffoldKey.currentState.showSnackBar(
          const SnackBar(content: const Text('Preferências salvas')),
        );

        Future.delayed(const Duration(milliseconds: 1000)).whenComplete(() {
          _scaffoldKey.currentState.removeCurrentSnackBar();
          Navigator.of(_scaffoldKey.currentContext).pop();
        });
      },
    );
  }

  Widget get _divider {
    return const Divider(indent: 8, endIndent: 8, height: 30);
  }
}
