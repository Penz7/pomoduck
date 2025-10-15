part of 'home_cubit.dart';

class HomeState extends BaseState {
  HomeState({
    super.status,
    super.message,
    this.data,
  });

  final List<TaskModel>? data;

  bool get hasData => data != null && data!.isNotEmpty;
  bool get isEmpty => data == null || data!.isEmpty;

  @override
  HomeState copyWith({
    BlocStatus? status,
    String? message,
    List<TaskModel>? data,
  }) {
    return HomeState(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }
}
