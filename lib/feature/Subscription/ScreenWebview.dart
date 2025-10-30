import 'package:flutter/material.dart';
import 'package:gastcallde/feature/Subscription/SubmissionCompleteScreen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../orderManagment/orderManagmentscreen.dart';

class ScreenWebview extends StatelessWidget {
  final String url;

  const ScreenWebview({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print("🔄 Page started loading: $url");
          },
          onPageFinished: (url) {
            print("✅ Page finished loading: $url");
          },
          onNavigationRequest: (request) {
            print("📡 Navigating to: ${request.url}");
            print(
              "🔍 Checking if URL contains 'success=success': ${request.url.contains('success=success')}",
            );

            if (request.url.contains('success=success')) {
              print(
                "🎉 Success URL detected! Navigating to order management screen",
              );
              // Use Future.delayed to ensure navigation happens after current frame
              Future.delayed(Duration.zero, () {
                Get.offAll(() => paymentCompleteScreen());
              });
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },

          onWebResourceError: (error) {
            print("❌ Web resource error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(url));

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: WebViewWidget(controller: controller),
    );
  }
}
