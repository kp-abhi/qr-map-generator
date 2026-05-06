export 'export_qr_stub.dart'
    if (dart.library.io) 'export_qr_mobile.dart'
    if (dart.library.js_interop) 'export_qr_web.dart';
