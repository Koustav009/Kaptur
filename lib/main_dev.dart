import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/main.dart';

/// Dev flavor entrypoint — talks to the local backend.
///
/// Android:  flutter run --flavor dev -t lib/main_dev.dart
/// Web:      flutter run --flavor dev -t lib/main_dev.dart -d chrome
void main() => bootstrap(AppFlavor.dev);
