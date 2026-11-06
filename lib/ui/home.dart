import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.email,
    required this.username,
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
  final String username;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your servers. One panel.', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: BlazeTheme.text)),
                    const SizedBox(height: 6),
                    Text('Welcome back, ${username.isNotEmpty ? username : email}.', style: const TextStyle(color: BlazeTheme.muted, fontSize: 15)),
                  ],
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  onChanged: onQuery,
                  style: const TextStyle(color: BlazeTheme.text),
                  decoration: blazeField('Search...').copyWith(labelText: null, hintText: 'Search...', hintStyle: const TextStyle(color: BlazeTheme.muted)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: servers.isEmpty
              ? const Center(child: Text('There are no servers associated with your account.', style: TextStyle(color: BlazeTheme.muted)))
              : LayoutBuilder(
                  builder: (context, c) {
                    final n = c.maxWidth >= 980 ? 2 : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: n,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        mainAxisExtent: 118,
                      ),
                      itemCount: servers.length,
                      itemBuilder: (_, i) => _Card(server: servers[i], api: api, onOpen: onOpen),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _Card extends StatefulWidget {
  const _Card({required this.server, required this.api, required this.onOpen});
  final BlazeServer server;
  final BlazeApi api;
  final ValueChanged<BlazeServer> onOpen;

  @override
  State<_Card> createState() => _CardState();
}

class _CardState extends State<_Card> {
  BlazeResources? res;

  @override
  void initState() {
    super.initState();
    widget.api.resources(widget.server.id).then((r) {
      if (mounted) setState(() => res = r);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    final state = res?.state ?? 'offline';
    final cpu = ((res?.cpu ?? 0) / 100).clamp(0.0, 1.0);
    final mem = s.memoryMb == 0 ? 0.0 : ((res?.memoryBytes ?? 0) / (s.memoryMb * 1024 * 1024)).clamp(0.0, 1.0);
    final disk = s.diskMb == 0 ? 0.0 : ((res?.diskBytes ?? 0) / (s.diskMb * 1024 * 1024)).clamp(0.0, 1.0);
    final stripe = state == 'running' ? BlazeTheme.ok : state == 'starting' || state == 'stopping' ? BlazeTheme.warn : BlazeTheme.bad;
    return Material(
      color: BlazeTheme.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => widget.onOpen(s),
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BlazeTheme.line),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: stripe,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: BlazeTheme.text)),
                      const SizedBox(height: 6),
                      Text(s.address.isEmpty ? s.node : s.address, style: const TextStyle(color: BlazeTheme.muted, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              Gauge(label: 'CPU', value: cpu, color: BlazeTheme.ok),
              Gauge(label: 'Memory', value: mem, color: BlazeTheme.warn),
              Gauge(label: 'Disk', value: disk, color: BlazeTheme.disk),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}
