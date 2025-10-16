import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'common/theme/colors.dart';
import 'data/models/pomodoro_settings.dart';
import 'data/models/current_timer_state.dart';
import 'data/models/user_preferences_model.dart';
import 'core/local_storage/local_storage_manager.dart';
import 'core/local_storage/hive_data_manager.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await Firebase.initializeApp();
//   debugPrint('Handling a background message: ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive adapters
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(PomodoroSettingsAdapter());
  Hive.registerAdapter(CurrentTimerStateAdapter());
  Hive.registerAdapter(UserPreferencesModelAdapter());
  
  // Initialize LocalStorage (secure + boxes) and open app-specific boxes
  await LocalStorageManager.instance.init();
  await HiveDataManager.initialize();

  await initConfig();
  // final loginInfo = await LocalStorageManager.instance.getData(LocalStorageKey.login);
  // String? language =
  // await LocalStorageManager.instance.getData(LocalStorageKey.language);
  // Determine start locale from persisted user preferences
  final persistedPreferences = HiveDataManager.getUserPreferences();
  final languageCode = (persistedPreferences.language).toLowerCase();
  final startLocale = languageCode == 'en'
      ? const Locale('en', 'US')
      : const Locale('vi', 'VN');
  const fallbackLocale = Locale('vi', 'VN');
  // if (language == "vi") {
  //   fallbackLocale = const Locale("vi", "VN");
  // }
  // FirebaseMessaging.onBackgroundMessage(
  //   _firebaseMessagingBackgroundHandler,
  // );
  GoRouter.optionURLReflectsImperativeAPIs = true;
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // debugPrint('FCM Token:\n$fcmToken\n');
  // runApp(!kReleaseMode
  //     ? DevicePreview(
  //         builder: (context) => EasyLocalization(
  //           supportedLocales: const [
  //             Locale('en', 'US'),
  //             Locale('vi', 'VN'),
  //           ],
  //           path: 'assets/translations',
  //           fallbackLocale: const Locale("vi", "VN"),
  //           child: const App(
  //             initLanguage: fallbackLocale,
  //             isSigned: isSigned,
  //           ),
  //         ),
  //       )
  //     : EasyLocalization(
  //         supportedLocales: const [
  //           Locale('en', 'US'),
  //           Locale('vi', 'VN'),
  //         ],
  //         path: 'assets/translations',
  //         fallbackLocale: const Locale("vi", "VN"),
  //         child: const App(
  //           initLanguage: fallbackLocale,
  //           isSigned: isSigned,
  //         ),
  //       ));

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: UIColors.white,
    ),
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('vi', 'VN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('vi', 'VN'),
      startLocale: startLocale,
      child: const App(
        initLanguage: fallbackLocale,
      ),
    ),
  );
}
