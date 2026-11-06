import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../compat/os.dart' if (dart.library.io) '../compat/os_io.dart';
import '../isolate/allowlist.dart';
import 'iframe_stub.dart' if (dart.library.html) 'iframe_web.dart';

bool get _embeddedWebView => !kIsWeb && (Os.isAndroid || Os.isIOS || Os.isMacOS);

class PanelShell extends StatefulWidget {
  const PanelShell({super.key, required this.startUrl});

  final String startUrl;

  @override
  State<PanelShell> createState() => _PanelShellState();
}

class _PanelShellState extends State<PanelShell> {
  WebViewController? _controller;
  var _loading = true;
  var _blocked = false;

  @override
  void initState() {
    super.initState();
    if (!_embeddedWebView) return;
    final start = Uri.parse(widget.startUrl);
    final target =
        BlazeAllowlist.allows(start) ? start : Uri.parse('https://${BlazeAllowlist.panel}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF080808))
      ..setUserAgent('BlazeHostingApp/1.0.0 (com.blazenxt.hosting; isolated)')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (req) {
            final uri = Uri.tryParse(req.url);
            if (!BlazeAllowlist.allows(uri)) {
              setState(() => _blocked = true);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(target);
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebPanelFrame(url: widget.startUrl);
    }
    final controller = _controller;
    if (controller == null) {
      return _DesktopOpen(url: widget.startUrl);
    }
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (_loading)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: Color(0xFFF97316),
                  backgroundColor: Colors.transparent,
                ),
              ),
            if (_blocked)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Material(
                  color: const Color(0xFF1C1917),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Blocked a site outside Blaze Hosting. This app only opens your own panel.',
                            style: TextStyle(color: Color(0xFFD6D3D1), fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() => _blocked = false),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DesktopOpen extends StatelessWidget {
  const _DesktopOpen({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Blaze Hosting',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xFFF97316),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'This window stays on your account only. In-app updates still run from Firebase Remote Config.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFA8A29E)),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF97316)),
                  onPressed: () {
                    final uri = Uri.parse(url);
                    if (BlazeAllowlist.allows(uri)) {
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: const Text('Open panel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
