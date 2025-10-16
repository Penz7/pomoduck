part of 'home_cubit.dart';

class HomeState extends BaseState {
  HomeState({
    super.status,
    super.message,
  });

  @override
  HomeState copyWith({
    BlocStatus? status,
    String? message,
  }) {
    return HomeState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
