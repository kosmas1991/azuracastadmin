import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'url_state.dart';

class UrlCubit extends Cubit<UrlState> {
  final String? initialUrl;
  UrlCubit({required this.initialUrl}) : super(UrlState(url: initialUrl ?? ''));

  emitNewUrl(String newUrl) {
    final formattedUrl = _formatUrl(newUrl);

    print('fian         URL IS           ${formattedUrl}');
    emit(state.copyWith(url: formattedUrl));
  }

  String _formatUrl(String url) {
    // If URL already has a scheme, return as is
    final uri = Uri.tryParse(url);
    if (uri != null && uri.hasScheme) {
      return url;
    }

    // Regular expression to check if the input is an IP address
    final ipRegex = RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$');
    if (ipRegex.hasMatch(url)) {
      return 'http://$url';
    }

    // If the input contains a dot (.) but no scheme, assume it's a domain and add https://
    if (url.contains('.')) {
      return 'https://$url';
    }

    // If none of the above conditions are met, return the original input
    return url;
  }
}
