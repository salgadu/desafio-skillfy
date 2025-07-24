const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:3001',
);
const int configTimeout = int.fromEnvironment(
  'CONFIG_TIMEOUT',
  defaultValue: 30,
);
const int configReceiveTimeout = int.fromEnvironment(
  'CONFIG_RECEIVE_TIMEOUT',
  defaultValue: 30,
);

const String themeModeKey = 'theme_mode';
