import 'package:flutter/material.dart';

import '../api/client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'account.dart';
import 'auth.dart';
import 'home.dart';
import 'server.dart';
import 'widgets.dart';

class BlazeNativeApp extends StatefulWidget {
  const BlazeNativeApp({super.key});

  @override
  State<BlazeNativeApp> createState() => _BlazeNativeAppState();
}

enum _Page { splash, login, register, home, server, account }

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
      setState(() => error = cleanErr(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _register({
    required String first,
    required String last,
    required String username,
    required String email,
    required String password,
  }) async {
    setState(() {
      busy = true;
      error = '';
    });
    try {
      await api.register(first: first, last: last, username: username, email: email, password: password);
      await _reload();
      setState(() => page = _Page.home);
    } catch (e) {
      setState(() => error = cleanErr(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _shell(String section, Widget child) {
    return PanelShell(
      email: api.email,
      section: section,
      onServers: () => setState(() {
        current = null;
        page = _Page.home;
      }),
      onAccount: () => setState(() => page = _Page.account),
      onLogout: () async {
        await api.logout();
        setState(() {
          servers = [];
          page = _Page.login;
        });
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blaze Hosting',
      debugShowCheckedModeBanner: false,
      theme: BlazeTheme.data(),
      home: switch (page) {
        _Page.splash => const _Splash(),
        _Page.login => LoginPage(
            busy: busy,
            error: error,
            onSubmit: _login,
            onCreate: () => setState(() {
              error = '';
              page = _Page.register;
            }),
          ),
        _Page.register => RegisterPage(
            busy: busy,
            error: error,
            onSubmit: _register,
            onBack: () => setState(() {
              error = '';
              page = _Page.login;
            }),
          ),
        _Page.home => _shell(
            'servers',
            HomePage(
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
              onLogout: () {},
              onAccount: () {},
              api: api,
            ),
          ),
        _Page.server => _shell(
            'servers',
            ServerPage(
              server: current!,
              api: api,
              onBack: () => setState(() {
                current = null;
                page = _Page.home;
              }),
            ),
          ),
        _Page.account => _shell('account', AccountPage(api: api, onBack: () => setState(() => page = _Page.home))),
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EmberBackdrop(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.asset('assets/logo.png', width: 96, height: 96)),
              const SizedBox(height: 16),
              const Text('Blaze Hosting', style: TextStyle(color: BlazeTheme.text, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.8)),
              const SizedBox(height: 6),
              const Text('Isolated · 1.0.0', style: TextStyle(color: BlazeTheme.muted)),
              const SizedBox(height: 24),
              const SizedBox(width: 140, child: LinearProgressIndicator(color: BlazeTheme.accent, backgroundColor: Color(0x22FFFFFF))),
            ],
          ),
        ),
      ),
    );
  }
}
