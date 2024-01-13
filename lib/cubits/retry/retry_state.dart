part of 'retry_cubit.dart';

class RetryState extends Equatable {
  final bool retry;

  RetryState({required this.retry});

  factory RetryState.initial() {
    return RetryState(retry: false);
  }

  @override
  List<Object> get props => [retry];

  RetryState copyWith({
    bool? retry,
  }) {
    return RetryState(
      retry: retry ?? this.retry,
    );
  }

  @override
  bool get stringify => true;
}
