import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'step_state.dart';

class StepCubit extends Cubit<StepState> {
  StepCubit() : super(StepState.initial());

  addOne() {
    emit(state.copyWith(step: state.step + 1));
  }

  setZero() {
    emit(state.copyWith(step: 0));
  }
}
