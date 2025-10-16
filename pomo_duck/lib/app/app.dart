import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomo_duck/app/router/app_router.dart';
import 'package:pomo_duck/common/global_bloc/config_pomodoro/config_pomodoro_cubit.dart';

import '../common/global_bloc/app/app_cubit.dart';
import '../common/global_bloc/language/language_cubit.dart';
import '../common/theme/colors.dart';

class App extends StatefulWidget {
  const App({
    super.key,
    required this.initLanguage,
  });

  final Locale initLanguage;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {

  double calculateWindowSize() {
    final devicePixel = View.of(context).devicePixelRatio;
    final size = View.of(context).physicalSize.height;
    return (size / devicePixel) * 3 / 4;
  }

  @override
  void initState() {
    super.initState();
    // AppLinkHelper.instance.registerAppLinkEvent();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => LanguageCubit(
              initLanguage: widget.initLanguage,
            ),
          ),
          BlocProvider(
            create: (_) => AppCubit(),
          ),
          BlocProvider(
            create: (_) => ConfigPomodoroCubit(),
          ),
          // BlocProvider(
          //   create: (_) => NotificationNumberCubit(),
          // ),
        ],
        child: BlocConsumer<LanguageCubit, LanguageState>(
          listener: (oldState, newState) {
            final engine = WidgetsFlutterBinding.ensureInitialized();
            engine.performReassemble();
          },
          builder: (context, state) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: TextScaler.noScaling,
                  ),
                  child: child!,
                );
              },
              theme: ThemeData(
                scaffoldBackgroundColor: UIColors.primaryColor,
                useMaterial3: true,
                appBarTheme: const AppBarTheme(
                  surfaceTintColor: Colors.white,
                ),
                // fontFamily: 'Biscuit Glitch',
                textTheme: GoogleFonts.dynaPuffTextTheme(
                  Theme.of(context).textTheme,
                ),
                textSelectionTheme: const TextSelectionThemeData(
                  cursorColor: UIColors.textColor,
                ),
                primaryColor: UIColors.primaryColor,
                primarySwatch: MaterialColor(
                  UIColors.primaryColor.value,
                  <int, Color>{
                    50: UIColors.primaryColor.withOpacity(0.1),
                    100: UIColors.primaryColor.withOpacity(0.2),
                    200: UIColors.primaryColor.withOpacity(0.3),
                    300: UIColors.primaryColor.withOpacity(0.4),
                    400: UIColors.primaryColor.withOpacity(0.5),
                    500: UIColors.primaryColor.withOpacity(0.6),
                    600: UIColors.primaryColor.withOpacity(0.7),
                    700: UIColors.primaryColor.withOpacity(0.8),
                    800: UIColors.primaryColor.withOpacity(0.9),
                    900: UIColors.primaryColor.withOpacity(1.0),
                  },
                ),
              ),
              // routeInformationParser: _rootRouter.defaultRouteParser(),
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: state.locale,
              routeInformationProvider:
              AppRouter.shareInstance.router.routeInformationProvider,
              routerDelegate: AppRouter.shareInstance.router.routerDelegate,
              routeInformationParser:
              AppRouter.shareInstance.router.routeInformationParser,
            );
          },
        ),
      ),
      onTap: () {
        if (FocusManager.instance.primaryFocus?.hasFocus == true) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
    );
  }
}
