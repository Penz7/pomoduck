import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../core/base_state.dart';

part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(AppState());

  // Future<void> logout() async {
  //   final device = await LazyData.deviceInfo ?? {};
  //   await APIService.instance.auth.logout({
  //     'deviceId': device['deviceId'],
  //   });
  //   //remove all data
  //   await LocalStorageHelper.instance.logout();
  //   EventBusProvider.fire(const ProfileRefreshEvent());
  // }
  //
  // Future<void> pushFCM() async {
  //   final fcm = await NotificationHelper.instance.fcmToken;
  //   final user = await LocalStorageHelper.instance.getCurrentUser();
  //   if (fcm != null && user != null) {
  //     //push
  //     final device = await LazyData.deviceInfo ?? {};
  //     await APIService.instance.auth.pushFCM({
  //       'deviceId': device['deviceId'],
  //       'fcmToken': fcm,
  //     });
  //   }
  // }
}