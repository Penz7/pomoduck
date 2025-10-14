part of 'language_cubit.dart';

class LanguageState extends BaseState {
  final Locale locale;

  LanguageState({
    super.message,
    super.status,
    required this.locale,
  });

  @override
  LanguageState copyWith({
    BlocStatus? status,
    String? message,
    Locale? locale,
  }) {
    return LanguageState(
      status: status ?? this.status,
      message: message,
      locale: locale!,
    );
  }
}


