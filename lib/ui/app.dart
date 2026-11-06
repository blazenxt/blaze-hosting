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
  final states = <String, String>{};
  BlazeServer? current;
  String query = '';
  String error = '';
  bool busy = false;

  String get username => api.account?.username ?? api.email.split('@').first;

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
    for (final s in servers) {
      api.resources(s.id).then((r) {
        if (mounted) setState(() => states[s.id] = r.state);
      }).catchError((_) {});
    }
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
      username: username,
      servers: servers,
      states: states,
      currentId: current?.id,
      section: section,
      onHome: () => setState(() {
        current = null;
        page = _Page.home;
      }),
      onOpen: (s) => setState(() {
        current = s;
        page = _Page.server;
      }),
      onAccount: () => setState(() => page = _Page.account),
      onLogout: () async {
        await api.logout();
        setState(() {
          servers = [];
          current = null;
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
              username: username,
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/login-hero.png', fit: BoxFit.cover),
          const ColoredBox(color: Color(0x99000000)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', width: 72, height: 72),
                const SizedBox(height: 12),
                const Text('BlazeNXT', style: TextStyle(color: BlazeTheme.accent, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 20),
                const SizedBox(width: 140, child: LinearProgressIndicator(color: BlazeTheme.accent, backgroundColor: Color(0x33FFFFFF))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
