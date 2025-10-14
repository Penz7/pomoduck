import 'package:flutter/material.dart';

class RouterKeyManager {
  static final instance = RouterKeyManager();
  final GlobalKey<NavigatorState> rootNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'root_key');
  final GlobalKey<NavigatorState> homeNavigatorKey =
  GlobalKey<NavigatorState>(debugLabel: 'home_key');
}
