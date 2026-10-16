import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:github_portfolio/app/app.dart';
import 'package:github_portfolio/app/di/app_dependencies.dart';

void main() {
  setUrlStrategy(PathUrlStrategy());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp(dependencies: AppDependencies.production()));
}
