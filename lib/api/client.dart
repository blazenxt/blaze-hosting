import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'adapter_stub.dart' if (dart.library.html) 'adapter_web.dart' as adapter;
import 'models.dart';

/// Isolated Blaze client. Talks only to panel.nawazfx.com, only /api/client
/// for the signed-in user. Never loads another origin.
class BlazeApi {
  BlazeApi()
      : dio = Dio(
          BaseOptions(
            baseUrl: origin,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 40),
            headers: {
              'Accept': 'application/json',
              'X-Requested-With': 'XMLHttpRequest',
            },
            validateStatus: (s) => s != null && s < 500,
          ),
        );

  static const origin = 'https://panel.nawazfx.com';

  final Dio dio;
  String email = '';
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    await adapter.attachAdapter(dio);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await adapter.xsrfToken(origin);
          if (token.isNotEmpty) {
            options.headers['X-XSRF-TOKEN'] = token;
          }
          handler.next(options);
        },
      ),
    );
    _ready = true;
  }

  Future<Map<String, dynamic>> _json(Response r) async {
    final data = r.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return data.cast<String, dynamic>();
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return {};
  }

  Future<void> csrf() async {
    await dio.get('/sanctum/csrf-cookie');
  }

  String _err(Map<String, dynamic> body, int status) {
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map && first['detail'] != null) return '${first['detail']}';
    }
    return body['message']?.toString() ?? 'HTTP $status';
  }

  Future<void> login(String user, String password) async {
    await csrf();
    final r = await dio.post('/auth/login', data: {'user': user, 'password': password});
    final body = await _json(r);
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception(_err(body, r.statusCode ?? 0));
    }
    final me = await dio.get('/api/client/account');
    final map = await _json(me);
    final attrs = (map['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
    email = '${attrs['email'] ?? user}';
  }

  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {}
    email = '';
  }

  Future<bool> restore() async {
    try {
      await csrf();
      final me = await dio.get('/api/client/account');
      if (me.statusCode == 200) {
        final map = await _json(me);
        final attrs = (map['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
        email = '${attrs['email'] ?? ''}';
        return email.isNotEmpty || me.statusCode == 200;
      }
    } catch (_) {}
    return false;
  }

  Future<List<BlazeServer>> servers() async {
    final r = await dio.get('/api/client');
    if (r.statusCode != 200) throw Exception('Could not load servers');
    final map = await _json(r);
    final data = map['data'];
    if (data is! List) return [];
    return data.map((e) => BlazeServer.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<BlazeResources> resources(String id) async {
    final r = await dio.get('/api/client/servers/$id/resources');
    final map = await _json(r);
    final a = (map['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
    final res = (a['resources'] as Map?)?.cast<String, dynamic>() ?? {};
    return BlazeResources(
      state: '${a['current_state'] ?? 'offline'}',
      memoryBytes: int.tryParse('${res['memory_bytes'] ?? 0}') ?? 0,
      cpu: double.tryParse('${res['cpu_absolute'] ?? 0}') ?? 0,
    );
  }

  Future<void> power(String id, String signal) async {
    final r = await dio.post('/api/client/servers/$id/power', data: {'signal': signal});
    if ((r.statusCode ?? 500) >= 300) {
      throw Exception(_err(await _json(r), r.statusCode ?? 0));
    }
  }

  Future<WebSocketChannel?> console(String id) async {
    final r = await dio.get('/api/client/servers/$id/websocket');
    final map = await _json(r);
    final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final token = '${data['token'] ?? ''}';
    final socket = '${data['socket'] ?? ''}';
    if (token.isEmpty || socket.isEmpty) return null;
    final uri = Uri.parse(socket);
    if (uri.host.isEmpty) return null;
    final ch = WebSocketChannel.connect(uri);
    ch.sink.add(jsonEncode({
      'event': 'auth',
      'args': [token],
    }));
    return ch;
  }
}
