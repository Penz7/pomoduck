import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtensionPlus on BuildContext {
  Future<T?> pushWithLastPath<T extends Object?>(
    String sub, {
    Map<String, dynamic>? params,
  }) async {
    final current = '${GoRouterState.of(this).uri}';
    return await push(
      '$current/$sub',
      extra: params,
    );
  }

  Future<void> pushReplaceLastPath(
    String newLastPath, {
    Map<String, dynamic>? params,
  }) async {
    final current = '${GoRouterState.of(this).uri}';
    final oldLastPath = current.split('/').last;
    return pushReplacement(
      current.replaceFirst(
        oldLastPath,
        newLastPath,
      ),
      extra: params,
    );
  }

  Future<T?> pushWithPath<T extends Object?>(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    return await push(
      path,
      extra: params,
    );
  }

  Future<void> goWithLastPath(
    String sub, {
    Map<String, dynamic>? params,
  }) async {
    final current = '${GoRouterState.of(this).uri}';
    return go(
      '$current/$sub',
      extra: params,
    );
  }

  Future<void> replaceWithPath(
      String path, {
        Map<String, dynamic>? params,
      }) async {
    return replace(
      path,
      extra: params,
    );
  }

  Future<void> goWithPath(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    return go(
      path,
      extra: params,
    );
  }

  void popUntilPath(String routePath) {
    final router = GoRouter.of(this);
    while (router.routerDelegate.currentConfiguration.matches.last.matchedLocation != routePath) {
      if (!router.canPop()) {
        return;
      }
      router.pop();
    }
  }
}
