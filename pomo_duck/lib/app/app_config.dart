import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/local_storage/local_storage.dart';
import 'app_bloc_observer.dart';

Future<void> initConfig() async {
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  // await Firebase.initializeApp();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // await FlutterConfigPlus.loadEnvVariables();
  HttpOverrides.global = MyHttpOverrides();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await LocalStorageManager.instance.init();
  // if (FlutterConfigPlus.get('ENVIRONMENT') == 'testing') {
  //   final result = await APIService.instance.auth.refreshToken();
  //   if (result.status == false) {
  //     await LocalStorageManager.instance.removeLoginInfo();
  //   }
  // }
  // final hasSeenIntro = await LocalStorageHelper.instance.hasSeenIntro();
  // LiveData.hasSeenIntro = hasSeenIntro ?? false;
  // LiveData.configs = await APIService.instance.config.getConfig();
  // final Map<String, dynamic> formatConfigs = {};
  // for (var element in LiveData.configs) {
  //   formatConfigs[element.key ?? ''] = element.value;
  // }
  // LiveData.formatConfigs = formatConfigs;
  // LiveData.cameras = await availableCameras();
  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (errorDetails) {
    if (kReleaseMode) {
      // FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
          X509Certificate cert,
          String host,
          int port,
          ) {
        return true;
      };
  }
}
