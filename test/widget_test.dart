import 'package:flutter_test/flutter_test.dart';
import 'package:hosting/api/client.dart';
import 'package:hosting/api/models.dart';
import 'package:hosting/isolate/allowlist.dart';
import 'package:hosting/update/update_models.dart';

void main() {
  test('client origin is isolated to the Blaze panel', () {
    expect(BlazeApi.origin, 'https://panel.nawazfx.com');
  });

  test('allowlist only Blaze hosts over https', () {
    expect(BlazeAllowlist.allows(Uri.parse('https://panel.nawazfx.com/auth/login')), true);
    expect(BlazeAllowlist.allows(Uri.parse('https://evil.example/steal')), false);
  });

  test('server json parse', () {
    final s = BlazeServer.fromJson({
      'attributes': {
        'identifier': 'abc12',
        'uuid': 'u',
        'name': 'box',
        'node': 'Blaze',
        'limits': {'memory': 512, 'disk': 1024},
        'description': '',
      },
    });
    expect(s.id, 'abc12');
    expect(s.memoryMb, 512);
  });

  test('version compare', () {
    expect(VersionUtil.isNewer('1.0.0', '1.0.1'), true);
    expect(VersionUtil.isNewer('1.0.0', '1.0.0'), false);
  });

  test('.env parse for variables tab', () {
    final m = parseEnv('# c\nFOO=bar\nexport BAZ="qux"\n');
    expect(m['FOO'], 'bar');
    expect(m['BAZ'], 'qux');
  });

  test('variable json parse', () {
    final v = BlazeVariable.fromJson({
      'attributes': {
        'name': 'Game',
        'description': 'id',
        'env_variable': 'GAME_ID',
        'server_value': '1',
        'is_editable': true,
      },
    });
    expect(v.env, 'GAME_ID');
    expect(v.value, '1');
  });
}
