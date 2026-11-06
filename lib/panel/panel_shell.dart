import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../compat/os.dart' if (dart.library.io) '../compat/os_io.dart';
import '../isolate/allowlist.dart';
import '../shell/blaze_chrome.dart';
import '../theme.dart';
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
      ..setBackgroundColor(BlazeTheme.bg)
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
      return BlazeChrome(child: WebPanelFrame(url: widget.startUrl));
    }
    final controller = _controller;
    if (controller == null) {
      return BlazeChrome(child: _DesktopHome(url: widget.startUrl));
    }
    return BlazeChrome(
      loading: _loading,
      child: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (_blocked)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Material(
                color: BlazeTheme.panel,
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Blocked a site outside Blaze Hosting. This app only opens your own panel.',
                    style: TextStyle(color: BlazeTheme.muted, fontSize: 13),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DesktopHome extends StatelessWidget {
  const _DesktopHome({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
      children: [
        Center(child: Image.asset('assets/logo.png', width: 72, height: 72)),
        const SizedBox(height: 14),
        const Text(
          'Your control plane',
          textAlign: TextAlign.center,
          style: TextStyle(color: BlazeTheme.text, fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        const Text(
          'Console, files, variables, backups — one account, isolated from everyone else.',
          textAlign: TextAlign.center,
          style: TextStyle(color: BlazeTheme.muted, height: 1.45),
        ),
        const SizedBox(height: 22),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: const [
            _Tile(title: 'Console', body: 'Live logs and power'),
            _Tile(title: 'Deploy', body: 'Minecraft, FiveM, Node, Python, PHP'),
            _Tile(title: 'Variables', body: 'Next to Files, .env detect'),
            _Tile(title: 'Keep-alive', body: 'Restart if the process dies'),
          ],
        ),
        const SizedBox(height: 28),
        Center(
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: BlazeTheme.accent,
              foregroundColor: const Color(0xFF1A0709),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            ),
            onPressed: () {
              final uri = Uri.parse(url);
              if (BlazeAllowlist.allows(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: const Text('Open panel'),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BlazeTheme.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BlazeTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(body, style: const TextStyle(color: BlazeTheme.muted, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}
