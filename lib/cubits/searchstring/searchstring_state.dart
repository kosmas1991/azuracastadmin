part of 'searchstring_cubit.dart';

class SearchstringState extends Equatable {
  final String searchString;

  SearchstringState({required this.searchString});

  factory SearchstringState.initial() {
    return SearchstringState(searchString: '');
  }

  @override
  List<Object> get props => [searchString];

  SearchstringState copyWith({
    String? searchString,
  }) {
    return SearchstringState(
      searchString: searchString ?? this.searchString,
    );
  }

  @override
  bool get stringify => true;
}