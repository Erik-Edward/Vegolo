import 'package:injectable/injectable.dart';

import 'telemetry_config.dart';

@module
abstract class TelemetryModule {
  @lazySingleton
  TelemetryConfig telemetryConfig() => TelemetryConfig.fromEnvironment();
}
