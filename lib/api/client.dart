import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'adapter_stub.dart' if (dart.library.html) 'adapter_web.dart' as adapter;
import 'models.dart';

/// Isolated Blaze client. Talks only to panel.nawazfx.com for the signed-in user.
class BlazeApi {
  BlazeApi()
      : dio = Dio(
          BaseOptions(
            baseUrl: origin,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 60),
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
  BlazeAccount? account;
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
      try {
        return jsonDecode(data) as Map<String, dynamic>;
      } catch (_) {}
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
    final bag = body['errors'];
    if (bag is Map && bag.isNotEmpty) {
      final v = bag.values.first;
      if (v is List && v.isNotEmpty) return '${v.first}';
      return '$v';
    }
    return body['message']?.toString() ?? 'HTTP $status';
  }

  void _ok(Response r, Map<String, dynamic> body) {
    if ((r.statusCode ?? 500) >= 300) {
      throw Exception(_err(body, r.statusCode ?? 0));
    }
  }

  Future<List<dynamic>> _list(String path, {Map<String, dynamic>? query}) async {
    final r = await dio.get(path, queryParameters: query);
    final body = await _json(r);
    _ok(r, body);
    final data = body['data'];
    return data is List ? data : [];
  }

  Future<void> _loadAccount() async {
    final me = await dio.get('/api/client/account');
    final map = await _json(me);
    _ok(me, map);
    account = BlazeAccount.fromJson(map);
    email = account!.email;
  }

  Future<void> login(String user, String password) async {
    await csrf();
    final r = await dio.post('/auth/login', data: {'user': user, 'password': password});
    final body = await _json(r);
    if (r.statusCode != 200 && r.statusCode != 204) {
      throw Exception(_err(body, r.statusCode ?? 0));
    }
    await _loadAccount();
  }

  Future<void> register({
    required String first,
    required String last,
    required String username,
    required String email,
    required String password,
  }) async {
    await csrf();
    final r = await dio.post('/auth/register', data: {
      'name_first': first,
      'name_last': last,
      'first_name': first,
      'last_name': last,
      'username': username,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
    final body = await _json(r);
    if ((r.statusCode ?? 500) >= 300) {
      throw Exception(_err(body, r.statusCode ?? 0));
    }
    await login(email, password);
  }

  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (_) {}
    email = '';
    account = null;
  }

  Future<bool> restore() async {
    try {
      await csrf();
      await _loadAccount();
      return email.isNotEmpty;
    } catch (_) {}
    return false;
  }

  Future<void> changePassword(String current, String next) async {
    final r = await dio.put('/api/client/account/password', data: {
      'current_password': current,
      'password': next,
      'password_confirmation': next,
    });
    _ok(r, await _json(r));
  }

  Future<List<BlazeApiKey>> apiKeys() async {
    final data = await _list('/api/client/account/api-keys');
    return data.map((e) => BlazeApiKey.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<BlazeApiKey> createApiKey(String description) async {
    final r = await dio.post('/api/client/account/api-keys', data: {
      'description': description,
      'allowed_ips': <String>[],
    });
    final body = await _json(r);
    _ok(r, body);
    return BlazeApiKey.fromJson(body);
  }

  Future<void> deleteApiKey(String id) async {
    final r = await dio.delete('/api/client/account/api-keys/$id');
    _ok(r, await _json(r));
  }

  Future<List<BlazeServer>> servers() async {
    final data = await _list('/api/client', query: {'include': 'allocations'});
    return data.map((e) => BlazeServer.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<BlazeResources> resources(String id) async {
    final r = await dio.get('/api/client/servers/$id/resources');
    final map = await _json(r);
    _ok(r, map);
    final a = (map['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
    final res = (a['resources'] as Map?)?.cast<String, dynamic>() ?? {};
    return BlazeResources(
      state: '${a['current_state'] ?? 'offline'}',
      memoryBytes: int.tryParse('${res['memory_bytes'] ?? 0}') ?? 0,
      cpu: double.tryParse('${res['cpu_absolute'] ?? 0}') ?? 0,
      diskBytes: int.tryParse('${res['disk_bytes'] ?? 0}') ?? 0,
    );
  }

  Future<BlazeSftp> sftp(String id) async {
    final r = await dio.get('/api/client/servers/$id');
    final map = await _json(r);
    _ok(r, map);
    final a = (map['attributes'] as Map?)?.cast<String, dynamic>() ?? {};
    final s = (a['sftp_details'] as Map?)?.cast<String, dynamic>() ?? {};
    return BlazeSftp(
      ip: '${s['ip'] ?? ''}',
      port: int.tryParse('${s['port'] ?? 2022}') ?? 2022,
    );
  }

  Future<void> power(String id, String signal) async {
    final r = await dio.post('/api/client/servers/$id/power', data: {'signal': signal});
    _ok(r, await _json(r));
  }

  Future<void> command(String id, String cmd) async {
    final r = await dio.post('/api/client/servers/$id/command', data: {'command': cmd});
    _ok(r, await _json(r));
  }

  Future<WebSocketChannel?> console(String id) async {
    final r = await dio.get('/api/client/servers/$id/websocket');
    final map = await _json(r);
    _ok(r, map);
    final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? {};
    final token = '${data['token'] ?? ''}';
    final socket = '${data['socket'] ?? ''}';
    if (token.isEmpty || socket.isEmpty) return null;
    final uri = Uri.parse(socket);
    if (uri.host.isEmpty) return null;
    final ch = WebSocketChannel.connect(uri);
    ch.sink.add(jsonEncode({'event': 'auth', 'args': [token]}));
    return ch;
  }

  Future<List<BlazeFile>> files(String id, String directory) async {
    final data = await _list('/api/client/servers/$id/files/list', query: {'directory': directory});
    return data.map((e) => BlazeFile.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<String> fileContents(String id, String path) async {
    final r = await dio.get(
      '/api/client/servers/$id/files/contents',
      queryParameters: {'file': path},
      options: Options(responseType: ResponseType.plain, headers: {'Accept': '*/*'}),
    );
    if ((r.statusCode ?? 500) >= 300) {
      throw Exception(_err(await _json(r), r.statusCode ?? 0));
    }
    return '${r.data ?? ''}';
  }

  Future<void> writeFile(String id, String path, String contents) async {
    final r = await dio.post(
      '/api/client/servers/$id/files/write',
      queryParameters: {'file': path},
      data: contents,
      options: Options(contentType: 'text/plain', headers: {'Accept': 'application/json'}),
    );
    _ok(r, await _json(r));
  }

  Future<void> mkdir(String id, String root, String name) async {
    final r = await dio.post('/api/client/servers/$id/files/create-folder', data: {'root': root, 'name': name});
    _ok(r, await _json(r));
  }

  Future<void> deleteFiles(String id, String root, List<String> names) async {
    final r = await dio.post('/api/client/servers/$id/files/delete', data: {'root': root, 'files': names});
    _ok(r, await _json(r));
  }

  Future<List<BlazeVariable>> variables(String id) async {
    final r = await dio.get('/api/client/servers/$id/startup');
    final map = await _json(r);
    _ok(r, map);
    final data = map['data'];
    if (data is! List) return [];
    return data.map((e) => BlazeVariable.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> setVariable(String id, String key, String value) async {
    final r = await dio.put('/api/client/servers/$id/startup/variable', data: {'key': key, 'value': value});
    _ok(r, await _json(r));
  }

  Future<Map<String, String>> envFromDotenv(String id) async {
    try {
      final raw = await fileContents(id, '/.env');
      return parseEnv(raw);
    } catch (_) {
      return {};
    }
  }

  Future<List<BlazeBackup>> backups(String id) async {
    final data = await _list('/api/client/servers/$id/backups');
    return data.map((e) => BlazeBackup.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> createBackup(String id, String name) async {
    final r = await dio.post('/api/client/servers/$id/backups', data: {'name': name, 'locked': false});
    _ok(r, await _json(r));
  }

  Future<void> restoreBackup(String id, String uuid) async {
    final r = await dio.post('/api/client/servers/$id/backups/$uuid/restore', data: {'truncate': true});
    _ok(r, await _json(r));
  }

  Future<void> deleteBackup(String id, String uuid) async {
    final r = await dio.delete('/api/client/servers/$id/backups/$uuid');
    _ok(r, await _json(r));
  }

  Future<List<BlazeDatabase>> databases(String id) async {
    final data = await _list('/api/client/servers/$id/databases', query: {'include': 'password'});
    return data.map((e) => BlazeDatabase.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> createDatabase(String id, String name) async {
    final r = await dio.post('/api/client/servers/$id/databases', data: {'database': name, 'remote': '%'});
    _ok(r, await _json(r));
  }

  Future<void> deleteDatabase(String id, String dbId) async {
    final r = await dio.delete('/api/client/servers/$id/databases/$dbId');
    _ok(r, await _json(r));
  }

  Future<List<BlazeAllocation>> allocations(String id) async {
    final data = await _list('/api/client/servers/$id/network/allocations');
    return data.map((e) => BlazeAllocation.fromJson((e as Map).cast<String, dynamic>())).toList();
  }

  Future<void> setPrimary(String id, int alloc) async {
    final r = await dio.post('/api/client/servers/$id/network/allocations/$alloc/primary');
    _ok(r, await _json(r));
  }

  Future<void> rename(String id, String name, String description) async {
    final r = await dio.post('/api/client/servers/$id/settings/rename', data: {'name': name, 'description': description});
    _ok(r, await _json(r));
  }

  Future<void> reinstall(String id) async {
    final r = await dio.post('/api/client/servers/$id/settings/reinstall');
    _ok(r, await _json(r));
  }
}
