part of 'radio_id_cubit.dart';

class RadioIdState extends Equatable {
  final int id;

  RadioIdState({required this.id});

  factory RadioIdState.initial() {
    return RadioIdState(id: 1);
  }

  @override
  List<Object> get props => [id];

  RadioIdState copyWith({
    int? id,
  }) {
    return RadioIdState(
      id: id ?? this.id,
    );
  }

  @override
  bool get stringify => true;
}
