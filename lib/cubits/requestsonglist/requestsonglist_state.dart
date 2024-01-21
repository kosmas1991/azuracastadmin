part of 'requestsonglist_cubit.dart';

class RequestsonglistState extends Equatable {
  final List<RequestSongData> list;

  RequestsonglistState({required this.list});

  factory RequestsonglistState.initial() {
    return RequestsonglistState(list: []);
  }

  @override
  List<Object> get props => [list];

  RequestsonglistState copyWith({
    List<RequestSongData>? list,
  }) {
    return RequestsonglistState(
      list: list ?? this.list,
    );
  }

  @override
  bool get stringify => true;
}