import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomo_duck/app/router/router_key_manager.dart';

import '../../features/common_page/maintain_screen.dart';
import '../../features/common_page/page_not_found_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/main_tabbar_screen.dart';
import '../../features/timer/timer_screen.dart';
import '../../features/common_page/settings_screen.dart';

class AppRouter {
  AppRouter._();

  static AppRouter? _instance;

  static AppRouter get shareInstance {
    _instance ??= AppRouter._();
    return _instance!;
  }

  late final router = GoRouter(
    initialLocation: initRouter(),
    navigatorKey: RouterKeyManager.instance.rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'shell',
        pageBuilder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return MaterialPage<void>(
            restorationId: 'shellWidget',
            child: MainTabBarScreen(navigationShell: navigationShell),
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            restorationScopeId: 'bHome',
            navigatorKey: RouterKeyManager.instance.homeNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/home',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    const MaterialPage<void>(
                  restorationId: 'home',
                  child: HomeScreen(),
                ),
                routes: const <RouteBase>[],
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'bStats',
            navigatorKey: RouterKeyManager.instance.statsNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/stats',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return MaterialPage<void>(
                    restorationId: 'calories',
                    child: Container(),
                  );
                },
                routes: const <RouteBase>[],
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'bTimeLine',
            navigatorKey: RouterKeyManager.instance.timeLineNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                // The screen to display as the root in the first tab of the
                // bottom navigation bar.
                path: '/time-line',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return MaterialPage<void>(
                    restorationId: 'time-line',
                    child: Container(),
                  );
                },
                routes: const <RouteBase>[],
              ),
            ],
          ),
          StatefulShellBranch(
            restorationScopeId: 'bSetting',
            navigatorKey: RouterKeyManager.instance.settingNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/setting',
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    MaterialPage<void>(
                  restorationId: 'setting',
                  child: Container(),
                ),
                routes: const <RouteBase>[],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
        builder: (BuildContext context, GoRouterState state) {
          return Container();
        },
        // routes: [
        //   GoRoute(
        //     path: 'password',
        //     parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
        //     builder: (BuildContext context, GoRouterState state) {
        //       final extra = state.extra as Map;
        //       return PasswordScreen(
        //         phone: extra['phone'],
        //       );
        //     },
        //   ),
        //   GoRoute(
        //     path: 'otp',
        //     parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
        //     builder: (BuildContext context, GoRouterState state) {
        //       final extra = state.extra as Map;
        //       return OTPScreen(
        //         phone: extra['phone'],
        //         fromForgot: extra['fromForgot'] as bool? ?? false,
        //       );
        //     },
        //   ),
        //   GoRoute(
        //     path: 'create_password',
        //     parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
        //     builder: (BuildContext context, GoRouterState state) {
        //       final extra = state.extra as Map;
        //       return CreatePasswordScreen(
        //         phone: extra['phone'],
        //         accessToken: extra['access_token'],
        //       );
        //     },
        //   ),
        // ],
      ),
      // GoRoute(
      //   path: '/nutrition_scan',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const NutritionScanScreen();
      //   },
      //   routes: <RouteBase>[
      //     GoRoute(
      //       path: 'detail',
      //       parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //       builder: (BuildContext context, GoRouterState state) {
      //         return const NutritionDetailScreen();
      //       },
      //     ),
      //   ],
      // ),
      // GoRoute(
      //   path: '/about-us',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const AboutUsScreen();
      //   },
      //   routes: const <RouteBase>[],
      // ),
      // GoRoute(
      //   path: '/trade-certification',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   builder: (BuildContext context, GoRouterState state) {
      //     return const TradeCertificationScreen();
      //   },
      //   routes: const <RouteBase>[],
      // ),
      // GoRoute(
      //   path: '/cart',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   builder: (context, state) {
      //     return const CartScreen();
      //   },
      //   routes: [
      //     GoRoute(
      //       path: 'voucher',
      //       parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //       builder: (context, state) {
      //         return const VoucherScreen();
      //       },
      //     ),
      //     GoRoute(
      //       path: 'payment',
      //       parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //       builder: (context, state) {
      //         return const PaymentScreen();
      //       },
      //       routes: [
      //         GoRoute(
      //           path: 'voucher',
      //           parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //           builder: (context, state) {
      //             return const VoucherScreen();
      //           },
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
      // GoRoute(
      //   path: '/product-search',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   pageBuilder: (
      //       BuildContext context,
      //       GoRouterState state,
      //       ) {
      //     return buildFadeTransition(
      //       context: context,
      //       state: state,
      //       child: const ProductSearchingScreen(),
      //     );
      //   },
      // ),
      // GoRoute(
      //   path: '/web-view/:url',
      //   parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
      //   builder: (context, state) {
      //     final params = state.pathParameters;
      //     return WebViewScreen(
      //       url: (params['url'] ?? '').decodeUrl,
      //     );
      //   },
      // ),
      GoRoute(
          path: '/maintaining',
          parentNavigatorKey: RouterKeyManager.instance.rootNavigatorKey,
          builder: (context, state) {
            return const MaintainScreen();
          }),
    ],
    redirect: _guard,
    errorBuilder: (context, state) {
      return const PageNotFoundScreen();
    },
  );

  String? initRouter() {
    //check maintaining
    // if (ConfigHelper.instance.isMaintaining) {
    //   return '/maintaining';
    // }
    // if (!LiveData.hasSeenIntro) {
    //   return '/intro';
    // }
    return '/home';
  }

  Future<String?> _guard(
    BuildContext context,
    GoRouterState state,
  ) async {
    // if (state.fullPath?.contains('/profile') == true) {
    //   final login = await LocalStorageManager.instance.checkLogin();
    //   if (login == true) {
    //     return null;
    //   }
    //   TempData.prePath = state.fullPath ?? '';
    //   return '/login';
    // }
    return null;
  }
}
