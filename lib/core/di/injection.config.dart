// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:vegolo/core/ai/gemma_service.dart' as _i432;
import 'package:vegolo/core/ai/model_manager.dart' as _i932;
import 'package:vegolo/core/camera/ocr_processor.dart' as _i235;
import 'package:vegolo/core/camera/scanner_service.dart' as _i517;
import 'package:vegolo/core/database/app_database.dart' as _i888;
import 'package:vegolo/core/database/scan_history_local_data_source.dart'
    as _i929;
import 'package:vegolo/features/history/data/repositories/scan_history_repository_impl.dart'
    as _i754;
import 'package:vegolo/features/history/data/thumbnail_generator.dart' as _i64;
import 'package:vegolo/features/history/domain/repositories/scan_history_repository.dart'
    as _i603;
import 'package:vegolo/features/ingredients/data/repositories/ingredient_repository_impl.dart'
    as _i1020;
import 'package:vegolo/features/ingredients/data/seed/ingredient_seed_loader.dart'
    as _i831;
import 'package:vegolo/features/ingredients/domain/repositories/ingredient_repository.dart'
    as _i314;
import 'package:vegolo/features/scanning/data/repositories/scanning_repository_impl.dart'
    as _i589;
import 'package:vegolo/features/scanning/domain/repositories/scanning_repository.dart'
    as _i708;
import 'package:vegolo/features/scanning/domain/services/rule_based_analyzer.dart'
    as _i164;
import 'package:vegolo/features/scanning/domain/usecases/perform_scan_analysis.dart'
    as _i475;
import 'package:vegolo/features/scanning/presentation/bloc/scanning_bloc.dart'
    as _i596;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i64.ThumbnailGenerator>(() => _i64.ThumbnailGenerator());
    gh.lazySingleton<_i932.ModelManager>(() => const _i932.ModelManager());
    gh.lazySingleton<_i432.GemmaService>(() => const _i432.GemmaService());
    gh.lazySingleton<_i888.AppDatabase>(() => _i888.AppDatabase());
    gh.lazySingleton<_i314.IngredientRepository>(
      () => _i1020.IngredientRepositoryImpl(gh<_i888.AppDatabase>()),
    );
    gh.lazySingleton<_i708.ScanningRepository>(
      () => const _i589.ScanningRepositoryImpl(),
    );
    gh.lazySingleton<_i235.OcrProcessor>(
      () => _i235.MlKitOcrProcessor(),
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i517.ScannerService>(() => _i517.CameraScannerService());
    gh.lazySingleton<_i929.ScanHistoryLocalDataSource>(
      () => _i929.DriftScanHistoryLocalDataSource(gh<_i888.AppDatabase>()),
    );
    gh.lazySingleton<_i831.IngredientSeedLoader>(
      () => _i831.IngredientSeedLoader(gh<_i314.IngredientRepository>()),
    );
    gh.lazySingleton<_i164.RuleBasedAnalyzer>(
      () => _i164.RuleBasedAnalyzer(gh<_i314.IngredientRepository>()),
    );
    gh.lazySingleton<_i603.ScanHistoryRepository>(
      () => _i754.ScanHistoryRepositoryImpl(
        gh<_i64.ThumbnailGenerator>(),
        gh<_i929.ScanHistoryLocalDataSource>(),
      ),
    );
    gh.lazySingleton<_i475.PerformScanAnalysis>(
      () => _i475.PerformScanAnalysis(gh<_i164.RuleBasedAnalyzer>()),
    );
    gh.factory<_i596.ScanningBloc>(
      () => _i596.ScanningBloc(
        scannerService: gh<_i517.ScannerService>(),
        ocrProcessor: gh<_i235.OcrProcessor>(),
        performScanAnalysis: gh<_i475.PerformScanAnalysis>(),
      ),
    );
    return this;
  }
}
