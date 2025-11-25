import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isProcessing = false;

  void _handleQrCode(BuildContext context, String qrData) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    // Basic validation for the URL structure
    final uri = Uri.tryParse(qrData);
    if (uri == null || !uri.queryParameters.containsKey('token')) {
      _showResultDialog('Invalid QR Code', 'This code is not a valid TVR Digital login code.');
      return;
    }

    final qrToken = uri.queryParameters['token']!;
    final authService = Provider.of<AuthService>(context, listen: false);

    final result = await authService.authorizeQrToken(qrToken);

    if (mounted) {
      if (result['success'] == true) {
        _showResultDialog('Success!', 'Your TV has been authorized. You can close this screen.', isSuccess: true);
      } else {
        _showResultDialog('Authorization Failed', result['message'] ?? 'An unknown error occurred.');
      }
    }
  }

  void _showResultDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Close the dialog
              if (isSuccess) {
                Navigator.of(context).pop(); // Go back from scanner screen
              }
              setState(() { _isProcessing = false; }); // Allow scanning again
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan TV QR Code'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                     _handleQrCode(context, barcodes.first.rawValue!);
                }
            },
          ),
          // Overlay with a centered scanning area indicator
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
