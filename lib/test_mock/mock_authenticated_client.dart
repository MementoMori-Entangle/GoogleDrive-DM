import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class MockAccessCredentials extends AccessCredentials {
  MockAccessCredentials()
      : super(
          AccessToken('Bearer', 'mock_access_token',
              DateTime.now().add(Duration(hours: 1))),
          'mock_refresh_token',
          ['mock_scope'],
        );
}

class MockAuthClient extends http.BaseClient {
  MockAuthClient();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = '{"mock": "send"}';
    final stream = Stream<List<int>>.fromIterable([utf8.encode(response)]);
    return http.StreamedResponse(stream, 200);
  }

  // Optional: add convenience methods for testing if needed
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
  Future<http.Response> put(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{"mock": "put"}', 200);
  }

  @override
  Future<http.Response> patch(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{"mock": "patch"}', 200);
  }

  @override
  Future<http.Response> delete(Uri url,
      {Map<String, String>? headers, Object? body, Encoding? encoding}) async {
    return http.Response('{"mock": "delete"}', 200);
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    return '{"mock": "read"}';
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    return Uint8List.fromList(utf8.encode('{"mock": "readBytes"}'));
  }

  @override
  void close() {
    // モックなので何もしない
  }
}
