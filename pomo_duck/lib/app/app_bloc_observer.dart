import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

// Comment: Log toàn bộ thay đổi state để debug
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('${bloc.runtimeType} $change');
  }
}