class AppConfig {
  static const String backendHost = String.fromEnvironment(
    'SMARTAGRI_BACKEND_HOST',
    defaultValue: '10.0.2.2',
  );
  static const int backendPort = int.fromEnvironment(
    'SMARTAGRI_BACKEND_PORT',
    defaultValue: 8000,
  );

  static String get apiBaseUrl => 'http://$backendHost:$backendPort';
  static String get websocketUrl => 'ws://$backendHost:$backendPort/ws';
}
