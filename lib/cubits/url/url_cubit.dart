import 'package:azuracastadmin/functions/functions.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'url_state.dart';

class UrlCubit extends Cubit<UrlState> {
  final String? initialUrl;
  UrlCubit({required this.initialUrl}) : super(UrlState(url: initialUrl ?? ''));

  emitNewUrl(String newUrl) {
    emit(state.copyWith(url: newUrl));
  }
}
