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
    await LocalStorageManager.instance.saveData(
      locale.languageCode,
      key: LocalStorageHiveKey.language,
    );
    emit(state.copyWith(
      locale: locale,
    ));
  }
}
