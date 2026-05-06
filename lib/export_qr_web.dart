import 'dart:convert';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web implementation: trigger a browser file download.
Future<String?> exportPngBytes(Uint8List pngBytes, String fileName) async {
  final base64 = base64Encode(pngBytes);
  final dataUrl = 'data:image/png;base64,$base64';

  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = dataUrl;
  anchor.download = fileName;
  anchor.style.display = 'none';

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  return null;
}
