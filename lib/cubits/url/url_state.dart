part of 'url_cubit.dart';

class UrlState extends Equatable {
  final String url;

  UrlState({required this.url});

  factory UrlState.initial() {
    return UrlState(url: '');
  }

  @override
  List<Object> get props => [url];

  UrlState copyWith({
    String? url,
  }) {
    printError('url cubit is: ${url}');
    return UrlState(
      url: url ?? this.url,
    );
  }

  @override
  bool get stringify => true;
}
