import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Mobile implementation: save to temp file and open share sheet.
Future<String?> exportPngBytes(Uint8List pngBytes, String fileName) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$fileName');
  await file.writeAsBytes(pngBytes);

  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Google Maps QR Code',
  );

  return file.path;
}
