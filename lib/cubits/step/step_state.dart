part of 'step_cubit.dart';

class StepState extends Equatable {
  final int step;

  StepState({required this.step});

  factory StepState.initial() {
    return StepState(step: 0);
  }

  @override
  List<Object> get props => [step];

  StepState copyWith({
    int? step,
  }) {
   
    return StepState(
      step: step ?? this.step,
    );
  }

  @override
  bool get stringify => true;
}
