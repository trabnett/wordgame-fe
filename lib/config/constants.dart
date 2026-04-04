import 'dart:html' as html;

String get _host {
  final hostname = html.window.location.hostname ?? 'localhost';
  return hostname == 'localhost' ? 'localhost:8181' : html.window.location.host;
}

String get _scheme => html.window.location.protocol.replaceAll(':', '');

String get apiBaseUrl => '$_scheme://$_host/api';
String get wsBaseUrl => '${_scheme == 'https' ? 'wss' : 'ws'}://$_host/ws';
