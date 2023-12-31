import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'api_state.dart';

class ApiCubit extends Cubit<ApiState> {
  final String initAPI;
  ApiCubit({required this.initAPI}) : super(ApiState(api: initAPI));

  emitNewApi(String newApi) {
    emit(state.copyWith(api: newApi));
  }
}
