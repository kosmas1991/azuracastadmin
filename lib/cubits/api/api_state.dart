part of 'api_cubit.dart';

class ApiState extends Equatable {
  final String api;

  ApiState({required this.api});

  factory ApiState.initial() {
    return ApiState(api: '');
  }

  @override
  List<Object> get props => [api];

  ApiState copyWith({
    String? api,
  }) {
    return ApiState(
      api: api ?? this.api,
    );
  }

  @override
  bool get stringify => true;
}
