import 'package:azuracastadmin/functions/functions.dart';
import 'package:azuracastadmin/models/requestsongdata.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
part 'requestsonglist_state.dart';

class RequestsonglistCubit extends Cubit<RequestsonglistState> {
  RequestsonglistCubit() : super(RequestsonglistState.initial()) {}

  emitNewList(List<RequestSongData> newList) {
    emit(state.copyWith(list: newList));
  }
}