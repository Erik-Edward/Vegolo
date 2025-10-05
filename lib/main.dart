import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/ingredients/data/seed/ingredient_seed_loader.dart';
import 'features/scanning/presentation/bloc/scanning_bloc.dart';
import 'features/scanning/presentation/pages/scanning_page.dart';
import 'shared/theme/app_theme.dart';
import 'shared/utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  // Seed ingredient DB on first run (best-effort).
  try {
    await getIt<IngredientSeedLoader>().ensureSeededIfEmpty();
  } catch (_) {
    // Ignore seeding errors in early MVP.
  }
  runApp(const VegoloApp());
}

class VegoloApp extends StatelessWidget {
  const VegoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ScanningBloc>(),
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.light,
        debugShowCheckedModeBanner: false,
        home: const ScanningPage(),
      ),
    );
  }
}
