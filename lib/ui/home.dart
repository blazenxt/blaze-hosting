import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.email,
    required this.servers,
    required this.query,
    required this.onQuery,
    required this.onOpen,
    required this.onPower,
    required this.onLogout,
    required this.onAccount,
    required this.api,
  });

  final String email;
  final List<BlazeServer> servers;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<BlazeServer> onOpen;
  final Future<void> Function(String id, String signal) onPower;
  final VoidCallback onLogout;
  final VoidCallback onAccount;
  final BlazeApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Image.asset('assets/logo.png', width: 36, height: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Blaze Hosting', style: TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700, fontSize: 16)),
                        Text(email, style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onAccount, child: const Text('Account', style: TextStyle(color: BlazeTheme.accentBright))),
                  TextButton(onPressed: onLogout, child: const Text('Log out', style: TextStyle(color: BlazeTheme.muted))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: onQuery,
                style: const TextStyle(color: BlazeTheme.text),
                decoration: InputDecoration(
                  hintText: 'Search servers',
                  hintStyle: const TextStyle(color: BlazeTheme.muted),
                  filled: true,
                  fillColor: BlazeTheme.panel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BlazeTheme.line)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: BlazeTheme.line)),
                ),
              ),
            ),
            Expanded(
              child: servers.isEmpty
                  ? const Center(child: Text('No servers on this account yet.', style: TextStyle(color: BlazeTheme.muted)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: servers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _Card(server: servers[i], api: api, onOpen: onOpen, onPower: onPower),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({required this.server, required this.api, required this.onOpen, required this.onPower});
  final BlazeServer server;
  final BlazeApi api;
  final ValueChanged<BlazeServer> onOpen;
  final Future<void> Function(String, String) onPower;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  String state = '…';

  @override
  void initState() {
    super.initState();
    widget.api.resources(widget.server.id).then((r) {
      if (mounted) setState(() => state = r.state);
    }).catchError((_) {});
  }

  Color get orb {
    if (state == 'running') return const Color(0xFF5EE9A8);
    if (state == 'starting' || state == 'stopping') return const Color(0xFFF5C36E);
    return const Color(0xFFFB7185);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    return Material(
      color: BlazeTheme.panel,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => widget.onOpen(s),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: orb, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Expanded(child: Text(s.name, style: const TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w600, fontSize: 16))),
              ]),
              const SizedBox(height: 6),
              Text('${s.node} · ${s.memoryMb} MB · $state', style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: (s.memoryMb / 2048).clamp(0.08, 1),
                  minHeight: 6,
                  color: BlazeTheme.accent,
                  backgroundColor: const Color(0xFF1F1F26),
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Pwr('Start', const Color(0xFF5EE9A8), () => widget.onPower(s.id, 'start')),
                const SizedBox(width: 8),
                Pwr('Restart', BlazeTheme.accentBright, () => widget.onPower(s.id, 'restart')),
                const SizedBox(width: 8),
                Pwr('Stop', const Color(0xFFFB7185), () => widget.onPower(s.id, 'stop')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
