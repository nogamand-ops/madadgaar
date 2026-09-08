/// Where the Madadgaar demo backend lives. All three apps default to the
/// same localhost server so their state stays in sync during a live demo.
/// Override at app start (e.g. `--dart-define=API_BASE_URL=...`) if the
/// server runs elsewhere.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');

  static String get wsUrl => '${apiBaseUrl.replaceFirst('http', 'ws')}/ws';
}
