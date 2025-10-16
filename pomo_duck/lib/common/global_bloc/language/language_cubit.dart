import 'dart:ui';

import 'package:bloc/bloc.dart';
import '../../../core/base_state.dart';
import '../../../core/local_storage/local_storage.dart';
import '../../../core/local_storage/hive_data_manager.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit({required this.initLanguage})
      : super(LanguageState(locale: initLanguage));

  final Locale initLanguage;

  Future<void> setNewLanguage(Locale locale) async {
    // Lưu ngôn ngữ vào Hive UserPreferences để đồng bộ toàn app
    final current = HiveDataManager.getUserPreferences();
    final updated = current.copyWith(language: locale.languageCode);
    await HiveDataManager.saveUserPreferences(updated);
    // Optional: lưu key ngắn gọn vào LazyBox để tương thích legacy
    await LocalStorageManager.instance.saveData(
      locale.languageCode,
      key: LocalStorageHiveKey.language,
    );
    emit(state.copyWith(
      locale: locale,
    ));
  }
}
