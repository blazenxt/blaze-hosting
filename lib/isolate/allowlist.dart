/// Hosts this app is allowed to load. Everything else is dropped.
class BlazeAllowlist {
  static const panel = 'panel.nawazfx.com';

  static const hosts = <String>{
    'panel.nawazfx.com',
    'nawazfx.com',
    'www.nawazfx.com',
    'community.nawazfx.com',
    'status.nawazfx.com',
  };

  static bool allows(Uri? uri) {
    if (uri == null) return false;
    if (uri.scheme != 'https' && uri.scheme != 'about') return false;
    if (uri.scheme == 'about') return true;
    final host = uri.host.toLowerCase();
    if (hosts.contains(host)) return true;
    if (host.endsWith('.nawazfx.com')) return true;
    return false;
  }
}
