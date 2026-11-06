import 'package:flutter/material.dart';

import 'isolate/allowlist.dart';
import 'panel/panel_shell.dart';
import 'shell/blaze_chrome.dart';
import 'theme.dart';
import 'update/update_gate.dart';
import 'update/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BlazeBoot());
}

class BlazeBoot extends StatefulWidget {
  const BlazeBoot({super.key});

  @override
  State<BlazeBoot> createState() => _BlazeBootState();
}

class _BlazeBootState extends State<BlazeBoot> {
  final updates = UpdateService();
  var ready = false;
  String start = 'https://${BlazeAllowlist.panel}';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await updates.boot();
      final panel = updates.snapshot?.panelUrl;
      if (panel != null && panel.startsWith('https://')) {
        start = panel;
      }
    } catch (_) {
      // Panel still opens; updates stay off until Firebase is configured.
    }
    if (mounted) setState(() => ready = true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaze Hosting',
      debugShowCheckedModeBanner: false,
      theme: BlazeTheme.data(),
      home: ready
          ? UpdateGate(
              service: updates,
              child: _Main(updates: updates, startUrl: start),
            )
          : const BlazeSplash(),
    );
  }
}

class _Main extends StatelessWidget {
  const _Main({required this.updates, required this.startUrl});

  final UpdateService updates;
  final String startUrl;

  @override
  Widget build(BuildContext context) {
    final maintenance = updates.snapshot?.maintenance ?? '';
    Widget body = PanelShell(startUrl: startUrl);
    if (maintenance.trim().isNotEmpty) {
      body = Column(
        children: [
          Material(
            color: const Color(0xFF7C2D12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(maintenance, style: const TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }
    return body;
  }
}
