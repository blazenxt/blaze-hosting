import 'dart:html' as html;

import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

Future<void> attachAdapter(Dio dio) async {
  dio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials = true;
}

Future<String> xsrfToken(String origin) async {
  final cookie = html.document.cookie ?? '';
  final match = RegExp(r'XSRF-TOKEN=([^;]+)').firstMatch(cookie);
  if (match == null) return '';
  return Uri.decodeComponent(match.group(1)!);
}
