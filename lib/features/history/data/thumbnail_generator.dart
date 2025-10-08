import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Creates and stores thumbnails for captured scan images. Concrete
/// implementation will run inside an isolate to avoid UI jank.
@LazySingleton()
class ThumbnailGenerator {
  Future<Uint8List> createThumbnail(
    Uint8List sourceBytes, {
    int maxDimension = 200,
  }) async {
    // Run heavy image work off the UI isolate to avoid jank.
    return Isolate.run(() => _createThumbnailSync(sourceBytes, maxDimension));
  }

  static Uint8List _createThumbnailSync(Uint8List sourceBytes, int maxDimension) {
    final source = img.decodeImage(sourceBytes);
    if (source == null) {
      return sourceBytes;
    }

    final aspect = source.width / source.height;
    int targetWidth;
    int targetHeight;
    if (source.width >= source.height) {
      targetWidth = maxDimension;
      targetHeight = (maxDimension / aspect).round();
    } else {
      targetHeight = maxDimension;
      targetWidth = (maxDimension * aspect).round();
    }
    if (targetWidth <= 0) targetWidth = 1;
    if (targetHeight <= 0) targetHeight = 1;

    final resized = img.copyResize(
      source,
      width: targetWidth,
      height: targetHeight,
      interpolation: img.Interpolation.linear,
    );

    return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
  }

  Future<String> persistThumbnail(Uint8List thumbnailBytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final thumbnailsDir = Directory(p.join(directory.path, 'thumbnails'));
    if (!await thumbnailsDir.exists()) {
      await thumbnailsDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = Random().nextInt(1 << 32).toRadixString(16);
    final filePath = p.join(
      thumbnailsDir.path,
      'thumb_${timestamp}_$randomSuffix.jpg',
    );

    final file = File(filePath);
    await file.writeAsBytes(thumbnailBytes, flush: true);
    return file.path;
  }
}
