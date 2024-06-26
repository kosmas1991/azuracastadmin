part of 'filteredlist_cubit.dart';

class FilteredlistState extends Equatable {
  final List<RequestSongData> filteredList;

  FilteredlistState({required this.filteredList});

  factory FilteredlistState.initial() {
    return FilteredlistState(filteredList: []);
  }

  @override
  List<Object> get props => [filteredList];

  FilteredlistState copyWith({
    List<RequestSongData>? filteredList,
  }) {
    return FilteredlistState(
      filteredList: filteredList ?? this.filteredList,
    );
  }

  @override
  bool get stringify => true;
}
