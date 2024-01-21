import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'searchstring_state.dart';

class SearchstringCubit extends Cubit<SearchstringState> {
  SearchstringCubit() : super(SearchstringState.initial());

  emitNewSearch(String newSearch) {
    emit(state.copyWith(searchString: newSearch));
  }
}