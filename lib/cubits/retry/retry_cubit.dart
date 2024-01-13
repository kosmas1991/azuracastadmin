import 'dart:async';

import 'package:azuracastadmin/cubits/step/step_cubit.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'retry_state.dart';

class RetryCubit extends Cubit<RetryState> {
  final StepCubit stepCubit;
  late final StreamSubscription stepStreamSubscription;
  RetryCubit({required this.stepCubit}) : super(RetryState.initial()) {
    stepStreamSubscription = stepCubit.stream.listen((StepState stepState) {
      if (stepState.step == 2) {
        emit(state.copyWith(retry: false));
      }
    });
  }

  emitNewState(bool newState) {
    emit(state.copyWith(retry: newState));
  }

  @override
  Future<void> close() {
    stepStreamSubscription.cancel();
    return super.close();
  }
}
