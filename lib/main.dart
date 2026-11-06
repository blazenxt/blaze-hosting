import 'package:flutter/material.dart';

import 'isolate/allowlist.dart';
import 'panel/panel_shell.dart';
import 'update/update_gate.dart';
import 'update/update_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final updates = UpdateService();
  String start = 'https://${BlazeAllowlist.panel}';
  String? bootError;
  try {
    await updates.boot();
    final panel = updates.snapshot?.panelUrl;
    if (panel != null && panel.startsWith('https://')) {
      start = panel;
    }
  } catch (e) {
    bootError = e.toString();
  }
  runApp(BlazeApp(updates: updates, startUrl: start, bootError: bootError));
}

class BlazeApp extends StatelessWidget {
  const BlazeApp({
    super.key,
    required this.updates,
    required this.startUrl,
    this.bootError,
  });

  final UpdateService updates;
  final String startUrl;
  final String? bootError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaze Hosting',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF97316),
          brightness: Brightness.dark,
          surface: const Color(0xFF080808),
        ),
        scaffoldBackgroundColor: const Color(0xFF080808),
        useMaterial3: true,
      ),
      home: _Home(updates: updates, startUrl: startUrl, bootError: bootError),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.updates,
    required this.startUrl,
    this.bootError,
  });

  final UpdateService updates;
  final String startUrl;
  final String? bootError;

  @override
  Widget build(BuildContext context) {
    final maintenance = updates.snapshot?.maintenance ?? '';
    Widget body = PanelShell(startUrl: startUrl);
    if (maintenance.trim().isNotEmpty) {
      body = _Maintenance(message: maintenance, child: body);
    }
    return UpdateGate(
      service: updates,
      child: Stack(
        children: [
          body,
          if (bootError != null && !updates.firebaseReady)
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _Maintenance extends StatelessWidget {
  const _Maintenance({required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: const Color(0xFF7C2D12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(message, style: const TextStyle(color: Colors.white)),
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
