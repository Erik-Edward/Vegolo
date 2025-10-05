import 'package:injectable/injectable.dart';

enum ModelVariant { nano, standard, full }

@LazySingleton()
class ModelManager {
  const ModelManager();

  Future<void> load(ModelVariant variant) async {
    throw UnimplementedError('ModelManager.load');
  }

  Future<void> unload() async {
    throw UnimplementedError('ModelManager.unload');
  }
}
