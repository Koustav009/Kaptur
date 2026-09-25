import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/main.dart';

/// Prod flavor entrypoint — talks to the production backend.
///
/// Android:  flutter run --flavor prod -t lib/main_prod.dart
/// Web:      flutter run --flavor prod -t lib/main_prod.dart -d chrome
void main() => bootstrap(AppFlavor.prod);
