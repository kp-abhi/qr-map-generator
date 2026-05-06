import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:url_launcher/url_launcher.dart';

import 'export_qr.dart' as export_qr;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maps QR Generator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MapsQrPage(),
    );
  }
}

class MapsQrPage extends StatefulWidget {
  const MapsQrPage({super.key});

  @override
  State<MapsQrPage> createState() => _MapsQrPageState();
}

class _MapsQrPageState extends State<MapsQrPage> {
  final _queryController = TextEditingController();
  final _qrKey = GlobalKey();
  String? _generatedUrl;
  String? _errorText;
  QrImage? _qrImage;

  static const _baseUrl = 'https://www.google.com/maps/search/?api=1';

  // Simple validation: coordinates pattern or non-empty place name
  static final _coordsPattern = RegExp(
    r'^-?\d{1,3}(\.\d+)?\s*,\s*-?\d{1,3}(\.\d+)?$',
  );

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _queryController.removeListener(_onInputChanged);
    _queryController.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final input = _queryController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _generatedUrl = null;
        _qrImage = null;
        _errorText = null;
      });
      return;
    }
    _generateLink();
  }

  String? _validateInput(String input) {
    if (input.isEmpty) return 'Please enter a location or coordinates';
    if (input.length > 500) return 'Input is too long (max 500 characters)';
    // If it looks like coordinates, validate the format
    if (RegExp(r'^-?\d').hasMatch(input) && !_coordsPattern.hasMatch(input)) {
      return 'Invalid coordinates format. Use: LAT,LONG (e.g. 37.7749,-122.4194)';
    }
    return null;
  }

  void _generateLink() {
    final input = _queryController.text.trim();
    final error = _validateInput(input);

    if (error != null) {
      setState(() {
        _errorText = error;
        _generatedUrl = null;
        _qrImage = null;
      });
      return;
    }

    final encodedQuery = Uri.encodeComponent(input);
    final url = '$_baseUrl&query=$encodedQuery';

    setState(() {
      _errorText = null;
      _generatedUrl = url;
      _qrImage = QrImage(QrCode.fromData(
        data: url,
        errorCorrectLevel: QrErrorCorrectLevel.H,
      ));
    });
  }

  Future<void> _testLink() async {
    if (_generatedUrl == null) return;
    final uri = Uri.parse(_generatedUrl!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }

  Future<void> _exportQrCode() async {
    try {
      final boundary = _qrKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final pngBytes = byteData.buffer.asUint8List();
      await export_qr.exportPngBytes(pngBytes, 'maps_qr_code.png');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kIsWeb ? 'Download started' : 'QR code shared successfully',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Maps QR Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: InputDecoration(
                labelText: 'Coordinates or Place Name',
                hintText: 'e.g. 37.7749,-122.4194 or Eiffel Tower',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.location_on),
                errorText: _errorText,
              ),
              onSubmitted: (_) => _generateLink(),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _generateLink,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
            if (_generatedUrl != null && _qrImage != null) ...[
              const SizedBox(height: 24),
              Center(
                child: RepaintBoundary(
                  key: _qrKey,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    width: 280,
                    height: 280,
                    child: PrettyQrView(
                      qrImage: _qrImage!,
                      decoration: PrettyQrDecoration(
                        image: const PrettyQrDecorationImage(
                          image: AssetImage('assets/maps_icon.png'),
                        ),
                        shape: PrettyQrSmoothSymbol(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _testLink,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Test Link'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _exportQrCode,
                    icon: Icon(kIsWeb ? Icons.download : Icons.save_alt),
                    label: Text(kIsWeb ? 'Download PNG' : 'Export PNG'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Generated URL:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SelectableText(
                _generatedUrl!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
