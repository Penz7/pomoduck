part of 'app_cubit.dart';

class AppState extends BaseState {

  AppState({
    super.message,
    super.status,
    this.badge = 0,
  });

  final int badge;

  @override
  AppState copyWith({
    BlocStatus? status,
    String? message,
    int? badge,
  }) {
    return AppState(
      status: status ?? this.status,
      message: message,
      badge: badge ?? this.badge,
    );
  }
}