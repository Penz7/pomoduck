import 'dart:ui';

import 'package:bloc/bloc.dart';
import '../../../core/base_state.dart';
import '../../../core/local_storage/local_storage.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({required this.initLanguage})
      : super(LanguageState(locale: initLanguage));

  final Locale initLanguage;

  Future<void> setNewLanguage(Locale locale) async {
    // Chỉ emit state, không save lại vì đã được save trong SettingCubit
    emit(state.copyWith(
      locale: locale,
    ));
  }
  
  /// Method để save language khi cần thiết (chỉ dùng khi không có SettingCubit)
  Future<void> setNewLanguageAndSave(Locale locale) async {
    final current = HiveDataManager.getUserPreferences();
    final updated = current.copyWith(language: locale.languageCode);
    await HiveDataManager.saveUserPreferences(updated);
    await LocalStorageManager.instance.saveData(
      locale.languageCode,
      key: LocalStorageHiveKey.language,
    );
    emit(state.copyWith(
      locale: locale,
    ));
  }
}
