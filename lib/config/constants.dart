String get _host {
  final uri = Uri.base;
  return uri.host == 'localhost' ? 'localhost:8181' : uri.host;
}

String get _scheme => Uri.base.scheme;

String get apiBaseUrl => '$_scheme://$_host/api';
String get wsBaseUrl => '${_scheme == 'https' ? 'wss' : 'ws'}://$_host/ws';
