import 'package:flutter/material.dart';

class RouterKeyManager {
  static final instance = RouterKeyManager();
  final GlobalKey<NavigatorState> rootNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'root_key');
  final GlobalKey<NavigatorState> homeNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'home_key');
  final GlobalKey<NavigatorState> statsNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'stats_key');
  final GlobalKey<NavigatorState> timeLineNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'time_line_key');
  final GlobalKey<NavigatorState> settingNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'setting_key');
}
