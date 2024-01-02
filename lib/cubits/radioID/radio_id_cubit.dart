import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'radio_id_state.dart';

class RadioIdCubit extends Cubit<RadioIdState> {
  RadioIdCubit() : super(RadioIdState.initial());

  emitNewID(int newID) {
    emit(state.copyWith(id: newID));
  }
}
