import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'app/app.dart';
import 'app/app_config.dart';
import 'common/theme/colors.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await Firebase.initializeApp();
//   debugPrint('Handling a background message: ${message.messageId}');
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initConfig();
  // final loginInfo = await LocalStorageManager.instance.getData(LocalStorageKey.login);
  // String? language =
  // await LocalStorageManager.instance.getData(LocalStorageKey.language);
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
      startLocale: const Locale('vi', 'VN'),
      child: const App(
        initLanguage: fallbackLocale,
      ),
    ),
  );
}
