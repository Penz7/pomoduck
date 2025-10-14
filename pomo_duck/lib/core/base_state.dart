enum BlocStatus { initial, loading, success, error }

abstract class BaseState {
  final BlocStatus status;
  final String? message;
  const BaseState({this.status = BlocStatus.initial, this.message});

  BaseState copyWith({BlocStatus? status, String? message});
}