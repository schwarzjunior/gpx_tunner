import 'package:flutter/material.dart' show Color, Colors;
import 'package:dynamic_theme_changer/dynamic_theme_changer.dart';

// Dark: Brown / Amber
const kDarkDarkPrimary = const Color(0xFF5D4037);
const kDarkLightPrimary = const Color(0xFFD7CCC8);
const kDarkPrimary = const Color(0xFF795548);
const kDarkTextIcons = const Color(0xFFFFFFFF);
const kDarkAccent = const Color(0xFFFFC107);
// const kDarkPrimaryText = const Color(0xFF212121);
const kDarkPrimaryText = const Color(0xFFFFFFFF);
const kDarkSecondaryText = const Color(0xFF757575);
const kDarkDivider = const Color(0xFFBDBDBD);
const kDarkScaffold = const Color(0xFF442B2D);

const kSwitchActive = const Color(0xFF76FF03);
const kSwitchActiveTrack = const Color(0xFF2E7D32);
const kSwitchInactiveThumb = const Color(0xFFFF80AB);
const kSwitchInactiveTrack = const Color(0xFFC62828);

// Light: Amber / Deep purple
const kLightDarkPrimary = const Color(0xFFFFA000);
const kLightLightPrimary = const Color(0xFFFFECB3);
const kLightPrimary = const Color(0xFFFFC107);
const kLightTextIcons = const Color(0xFF212121);
const kLightAccent = const Color(0xFF7C4DFF);
const kLightPrimaryText = const Color(0xFF212121);
const kLightSecondaryText = const Color(0xFF757575);
const kLightDivider = const Color(0xFFBDBDBD);
const kLightScaffold = const Color(0xFFFFFFFF);

const kDarkHintColor = const Color(0xFFB57100);

class AppThemes {
  static Future<void> initThemes() async {
    ThemeStore store = ThemeStore.instance;

    store.addTheme(ThemeFull(
      "Default",
      light: ThemeSingle(
        primaryColor: kLightPrimary,
        accentColor: Colors.yellow[800],
        buttonColor: kDarkAccent,
        splashColor: Colors.yellow[600],
        scaffoldBackgroundColor: kLightScaffold,
        hintColor: kDarkHintColor,
      ),
      dark: ThemeSingle(
        primaryColor: Colors.brown[900],
        accentColor: Colors.grey,
        buttonColor: Colors.black,
        splashColor: Colors.grey[600],
        scaffoldBackgroundColor: Colors.grey[700],
        disabledColor: Colors.grey[600],
        backgroundColor: Colors.black54,
        hintColor: Colors.grey[600],
      ),
    ));

    await ThemeBloc.init();
  }
}
