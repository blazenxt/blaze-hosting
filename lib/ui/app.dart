import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';

class BlazeNativeApp extends StatefulWidget {
  const BlazeNativeApp({super.key});

  @override
  State<BlazeNativeApp> createState() => _BlazeNativeAppState();
}

enum _Page { splash, login, home, server }

class _BlazeNativeAppState extends State<BlazeNativeApp> {
  final api = BlazeApi();
  _Page page = _Page.splash;
  List<BlazeServer> servers = [];
  BlazeServer? current;
  String query = '';
  String error = '';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await api.init();
    final ok = await api.restore();
    if (!mounted) return;
    if (ok) {
      await _reload();
      setState(() => page = _Page.home);
    } else {
      setState(() => page = _Page.login);
    }
  }

  Future<void> _reload() async {
    servers = await api.servers();
    if (mounted) setState(() {});
  }

  Future<void> _login(String user, String pass) async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await api.login(user, pass);
      await _reload();
      setState(() => page = _Page.home);
    } catch (e) {
      setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaze Hosting',
      debugShowCheckedModeBanner: false,
      theme: BlazeTheme.data(),
      home: switch (page) {
        _Page.splash => const _Splash(),
        _Page.login => _Login(busy: busy, error: error, onSubmit: _login),
        _Page.home => _Home(
            email: api.email,
            servers: servers.where((s) => query.isEmpty || s.name.toLowerCase().contains(query.toLowerCase())).toList(),
            query: query,
            onQuery: (v) => setState(() => query = v),
            onOpen: (s) => setState(() {
              current = s;
              page = _Page.server;
            }),
            onPower: (id, sig) async {
              await api.power(id, sig);
              await _reload();
            },
            onLogout: () async {
              await api.logout();
              setState(() {
                servers = [];
                page = _Page.login;
              });
            },
            api: api,
          ),
        _Page.server => _ServerView(
            server: current!,
            api: api,
            onBack: () => setState(() {
              current = null;
              page = _Page.home;
            }),
          ),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/logo.png', width: 96, height: 96),
            const SizedBox(height: 16),
            const Text('Blaze Hosting', style: TextStyle(color: BlazeTheme.text, fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Isolated · 1.0.0', style: TextStyle(color: BlazeTheme.muted)),
            const SizedBox(height: 24),
            const SizedBox(width: 140, child: LinearProgressIndicator(color: BlazeTheme.accent, backgroundColor: Color(0x22FFFFFF))),
          ],
        ),
      ),
    );
  }
}

class _Login extends StatefulWidget {
  const _Login({required this.busy, required this.error, required this.onSubmit});
  final bool busy;
  final String error;
  final void Function(String, String) onSubmit;

  @override
  State<_Login> createState() => _LoginState();
}

class _LoginState extends State<_Login> {
  final user = TextEditingController();
  final pass = TextEditingController();

  @override
  void dispose() {
    user.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fill = OutlineInputBorder(borderSide: BorderSide(color: BlazeTheme.line), borderRadius: BorderRadius.all(Radius.circular(12)));
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 64, height: 64),
                const SizedBox(height: 14),
                const Text('Welcome back.', style: TextStyle(color: BlazeTheme.text, fontSize: 30, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                const Text('Only your servers. Only your account.', style: TextStyle(color: BlazeTheme.muted)),
                const SizedBox(height: 22),
                TextField(
                  controller: user,
                  style: const TextStyle(color: BlazeTheme.text),
                  decoration: const InputDecoration(
                    labelText: 'Email or username',
                    labelStyle: TextStyle(color: BlazeTheme.muted),
                    enabledBorder: fill,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BlazeTheme.accent), borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pass,
                  obscureText: true,
                  style: const TextStyle(color: BlazeTheme.text),
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: BlazeTheme.muted),
                    enabledBorder: fill,
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: BlazeTheme.accent), borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                ),
                if (widget.error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(widget.error, style: const TextStyle(color: Color(0xFFFB7185))),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: BlazeTheme.accent, foregroundColor: const Color(0xFF1A0709)),
                    onPressed: widget.busy ? null : () => widget.onSubmit(user.text.trim(), pass.text),
                    child: Text(widget.busy ? 'Signing in…' : 'Sign in', style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({
    required this.email,
    required this.servers,
    required this.query,
    required this.onQuery,
    required this.onOpen,
    required this.onPower,
    required this.onLogout,
    required this.api,
  });

  final String email;
  final List<BlazeServer> servers;
  final String query;
  final ValueChanged<String> onQuery;
  final ValueChanged<BlazeServer> onOpen;
  final Future<void> Function(String id, String signal) onPower;
  final VoidCallback onLogout;
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x73C94F59)),
                      borderRadius: BorderRadius.circular(99),
                      color: const Color(0x22C94F59),
                    ),
                    child: const Text('ISOLATED', style: TextStyle(color: BlazeTheme.accentBright, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                  ),
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
                  ? const Center(child: Text('No servers on this account.', style: TextStyle(color: BlazeTheme.muted)))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      itemCount: servers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _ServerCard(server: servers[i], api: api, onOpen: onOpen, onPower: onPower),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerCard extends StatefulWidget {
  const _ServerCard({required this.server, required this.api, required this.onOpen, required this.onPower});
  final BlazeServer server;
  final BlazeApi api;
  final ValueChanged<BlazeServer> onOpen;
  final Future<void> Function(String, String) onPower;

  @override
  State<_ServerCard> createState() => _ServerCardState();
}

class _ServerCardState extends State<_ServerCard> {
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
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: orb, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.name, style: const TextStyle(color: BlazeTheme.text, fontWeight: FontWeight.w600, fontSize: 16))),
                ],
              ),
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
              Row(
                children: [
                  _Pwr('Start', const Color(0xFF5EE9A8), () => widget.onPower(s.id, 'start')),
                  const SizedBox(width: 8),
                  _Pwr('Restart', BlazeTheme.accentBright, () => widget.onPower(s.id, 'restart')),
                  const SizedBox(width: 8),
                  _Pwr('Stop', const Color(0xFFFB7185), () => widget.onPower(s.id, 'stop')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pwr extends StatelessWidget {
  const _Pwr(this.label, this.color, this.onTap);
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.4)),
        shape: const StadiumBorder(),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _ServerView extends StatefulWidget {
  const _ServerView({required this.server, required this.api, required this.onBack});
  final BlazeServer server;
  final BlazeApi api;
  final VoidCallback onBack;

  @override
  State<_ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<_ServerView> {
  final logs = <String>[];
  WebSocketChannel? ch;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  Future<void> _connect() async {
    final sock = await widget.api.console(widget.server.id);
    if (!mounted || sock == null) return;
    ch = sock;
    sock.stream.listen((raw) {
      try {
        final msg = jsonDecode(raw is String ? raw : utf8.decode(raw as List<int>)) as Map;
        final event = '${msg['event']}';
        if (event == 'auth success') {
          sock.sink.add(jsonEncode({'event': 'send logs', 'args': [null]}));
        }
        if (event == 'console output' || event == 'install output') {
          final args = msg['args'];
          final line = args is List && args.isNotEmpty ? '${args.first}' : '';
          setState(() {
            logs.add(line);
            if (logs.length > 400) logs.removeAt(0);
          });
        }
      } catch (_) {}
    }, onError: (_) {}, onDone: () {});
  }

  @override
  void dispose() {
    ch?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.server;
    return Scaffold(
      backgroundColor: BlazeTheme.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton(onPressed: widget.onBack, child: const Text('← Servers', style: TextStyle(color: BlazeTheme.accentBright, fontWeight: FontWeight.w700))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(s.name, style: const TextStyle(color: BlazeTheme.text, fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(s.id, style: const TextStyle(color: BlazeTheme.muted, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _Pwr('Start', const Color(0xFF5EE9A8), () => widget.api.power(s.id, 'start')),
                  const SizedBox(width: 8),
                  _Pwr('Restart', BlazeTheme.accentBright, () => widget.api.power(s.id, 'restart')),
                  const SizedBox(width: 8),
                  _Pwr('Stop', const Color(0xFFFB7185), () => widget.api.power(s.id, 'stop')),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF050506), borderRadius: BorderRadius.circular(14), border: Border.all(color: BlazeTheme.line)),
                child: SingleChildScrollView(
                  reverse: true,
                  child: SelectableText(
                    logs.isEmpty ? 'Waiting for console…' : logs.join(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Color(0xFFD1D5DB), height: 1.45),
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
