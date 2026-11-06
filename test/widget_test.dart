import 'package:flutter_test/flutter_test.dart';
import 'package:hosting/isolate/allowlist.dart';
import 'package:hosting/update/update_models.dart';

void main() {
  test('allowlist only Blaze hosts over https', () {
    expect(BlazeAllowlist.allows(Uri.parse('https://panel.nawazfx.com/auth/login')), true);
    expect(BlazeAllowlist.allows(Uri.parse('https://evil.example/steal')), false);
    expect(BlazeAllowlist.allows(Uri.parse('http://panel.nawazfx.com')), false);
  });

  test('version compare', () {
    expect(VersionUtil.isNewer('1.0.0', '1.0.1'), true);
    expect(VersionUtil.isNewer('1.0.1', '1.0.0'), false);
    expect(VersionUtil.isNewer('1.0.0', '1.0.0'), false);
    expect(VersionUtil.belowMin('1.0.0', '1.1.0'), true);
    expect(VersionUtil.belowMin('1.1.0', '1.1.0'), false);
  });
}
