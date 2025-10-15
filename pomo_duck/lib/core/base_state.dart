enum BlocStatus {
  initial,
  loading,
  success,
  checking,
  error,
  validateError,
}

class BaseState {
  BaseState({
    this.status = BlocStatus.initial,
    String? message,
  }) {
    if (status != BlocStatus.error) {
      message = null;
    } else {
      this.message = message;
    }
  }

  final BlocStatus? status;
  String? message;

  bool get isLoading {
    return status == BlocStatus.loading;
  }

  bool get isSuccess {
    return status == BlocStatus.success;
  }

  bool get isValidateError {
    return status == BlocStatus.validateError;
  }

  bool get isError {
    return status == BlocStatus.error;
  }

  bool get isChecking {
    return status == BlocStatus.checking;
  }

  BaseState copyWith({
    BlocStatus? status,
    String? message,
  }) {
    return BaseState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
