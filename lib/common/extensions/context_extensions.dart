import 'package:flutter/material.dart';
import 'package:github_portfolio/l10n/app_localizations.dart';

extension BuildContextExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get padding => MediaQuery.of(this).padding;
}
