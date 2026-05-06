import 'dart:typed_data';

/// Platform-agnostic interface for exporting QR code PNG bytes.
Future<String?> exportPngBytes(Uint8List pngBytes, String fileName) {
  throw UnsupportedError('Cannot export without a platform implementation');
}
