import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// AuthClientのモック相当（googleapis_auth 2.x対応）
class MockAuthClient extends http.BaseClient {
  MockAuthClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = '{"mock": "send"}';
    final stream = Stream<List<int>>.fromIterable([utf8.encode(response)]);
    return http.StreamedResponse(stream, 200);
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    return http.Response('{"mock": "get"}', 200);
  }

  @override
  Future<http.Response> post(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{"mock": "post"}', 200);
  }

  @override
  void close() {
    // モックなので何もしない
  }
}
