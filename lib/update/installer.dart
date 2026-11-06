import 'install_backend.dart' if (dart.library.io) 'install_backend_io.dart' as backend;

typedef ProgressFn = void Function(int received, int total);

class Installer {
  Installer();

  Future<void> install({
    required String url,
    required ProgressFn onProgress,
  }) {
    return backend.runNativeInstall(url: url, onProgress: onProgress);
  }
}
