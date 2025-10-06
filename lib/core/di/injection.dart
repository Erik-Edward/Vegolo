import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(generateForDir: ['lib'])
Future<void> configureDependencies() async {
  await getIt.init();
}
