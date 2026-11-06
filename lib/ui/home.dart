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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 8),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Servers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1, color: BlazeTheme.text)),
                    SizedBox(height: 4),
                    Text('Your machines only. Search, power, open console.', style: TextStyle(color: BlazeTheme.muted)),
                  ],
                ),
              ),
              SizedBox(
                width: 280,
                child: TextField(
                  onChanged: onQuery,
                  style: const TextStyle(color: BlazeTheme.text),
                  decoration: blazeField('Search files · power · logs').copyWith(labelText: 'Search servers'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: servers.isEmpty
              ? const Center(child: Text('No servers on this account yet.', style: TextStyle(color: BlazeTheme.muted)))
              : LayoutBuilder(
                  builder: (context, c) {
                    final n = c.maxWidth >= 1180 ? 3 : c.maxWidth >= 720 ? 2 : 1;
                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(28, 12, 28, 32),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: n,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: n == 1 ? 1.55 : 1.35,
                      ),
                      itemCount: servers.length,
                      itemBuilder: (_, i) => _Card(server: servers[i], api: api, onOpen: onOpen, onPower: onPower),
                    );
                  },
                ),
        ),
      ],
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
    final state = res?.state ?? '…';
    final mem = res == null || s.memoryMb == 0 ? 0.08 : (res!.memoryBytes / (s.memoryMb * 1024 * 1024)).clamp(0.06, 1);
    return GlassCard(
      onTap: () => widget.onOpen(s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusOrb(state),
              const SizedBox(width: 8),
              Expanded(child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700, fontSize: 16))),
              Text(state.toUpperCase(), style: const TextStyle(color: BlazeTheme.muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 8),
          Text('${s.node}  ·  ${s.memoryMb} MB RAM  ·  ${s.diskMb} MB disk', style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: _Stat('CPU', '${(res?.cpu ?? 0).toStringAsFixed(0)}%'),
              ),
              Expanded(
                child: _Stat('MEM', '${((res?.memoryBytes ?? 0) / (1024 * 1024)).toStringAsFixed(0)} MB'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: mem.toDouble(),
              minHeight: 6,
              color: BlazeTheme.accent,
              backgroundColor: const Color(0xFF1F1F26),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Pwr('Start', BlazeTheme.ok, () => widget.onPower(s.id, 'start')),
            const SizedBox(width: 8),
            Pwr('Restart', BlazeTheme.accentBright, () => widget.onPower(s.id, 'restart')),
            const SizedBox(width: 8),
            Pwr('Stop', BlazeTheme.bad, () => widget.onPower(s.id, 'stop')),
          ]),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(k, style: const TextStyle(color: BlazeTheme.muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        Text(v, style: const TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
