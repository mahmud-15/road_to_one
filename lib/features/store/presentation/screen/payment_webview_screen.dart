import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../utils/constants/app_colors.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onSuccess;
  final List<String> successUrlContains;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.onSuccess,
    this.successUrlContains = const <String>[
      'success',
      'payment-success',
      'thank_you',
      'thank-you',
      'status=paid',
      'payment_intent',
    ],
  });







  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _didComplete = false;

  bool _isSuccessUrl(String url) {
    final lower = url.toLowerCase();
    return widget.successUrlContains.any((k) => lower.contains(k.toLowerCase()));
  }

  void _handleUrlChange(String url) {
    if (_didComplete) {
      return;
    }
    if (_isSuccessUrl(url)) {
      _didComplete = true;
      widget.onSuccess();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            _handleUrlChange(request.url);
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroudColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroudColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Checkout'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFb4ff39),
              ),
            ),
        ],
      ),
    );
  }
}
