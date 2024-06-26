import 'dart:async';
import 'package:azuracastadmin/cubits/requestsonglist/requestsonglist_cubit.dart';
import 'package:azuracastadmin/cubits/searchstring/searchstring_cubit.dart';
import 'package:azuracastadmin/models/requestsongdata.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'filteredlist_state.dart';

class FilteredlistCubit extends Cubit<FilteredlistState> {
  final List<RequestSongData> initialList;
  final RequestsonglistCubit requestsonglistCubit;
  final SearchstringCubit searchstringCubit;
  late final StreamSubscription searchStreamSubscription;
  FilteredlistCubit(
      {required this.requestsonglistCubit,
      required this.searchstringCubit,
      required this.initialList})
      : super(FilteredlistState(filteredList: initialList)) {
    searchStreamSubscription =
        searchstringCubit.stream.listen((SearchstringState event) {
      if (event.searchString.isEmpty || event.searchString == '') {
        emitNewFilteredList(requestsonglistCubit.state.list);
      } else {
        List<RequestSongData> newCreatedList =
            requestsonglistCubit.state.list.where((RequestSongData e) {
          if (e.song!.artist!
                  .toLowerCase()
                  .contains('${event.searchString}'.toLowerCase()) ||
              e.song!.title!
                  .toLowerCase()
                  .contains('${event.searchString}'.toLowerCase())) {
            return true;
          } else {
            return false;
          }
        }).toList();
        emitNewFilteredList(newCreatedList);
      }
    });
  }

  emitNewFilteredList(List<RequestSongData> newList) {
    emit(state.copyWith(filteredList: newList));
  }

  @override
  Future<void> close() {
    searchStreamSubscription.cancel();
    return super.close();
  }
}