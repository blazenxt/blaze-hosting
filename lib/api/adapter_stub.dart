import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';

PersistCookieJar? blazeJar;

Future<void> attachAdapter(Dio dio) async {
  final dir = await getApplicationSupportDirectory();
  blazeJar = PersistCookieJar(storage: FileStorage('${dir.path}/blaze_cookies'));
  dio.interceptors.add(CookieManager(blazeJar!));
}

Future<String> xsrfToken(String origin) async {
  final list = await blazeJar?.loadForRequest(Uri.parse(origin)) ?? [];
  for (final c in list) {
    if (c.name == 'XSRF-TOKEN') {
      return Uri.decodeComponent(c.value);
    }
  }
  return '';
}
