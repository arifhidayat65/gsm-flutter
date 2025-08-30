import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final Uri? baseUri;
  final Duration timeout;
  final Map<String, String> defaultHeaders;
  bool _logging = false;
  void Function(String message)? _logger;

  ApiClient({
    this.baseUri,
    this.timeout = const Duration(seconds: 20),
    this.defaultHeaders = const {
      'Accept': 'application/json',
    },
    bool logging = false,
    void Function(String message)? logger,
  })  : _logging = logging, _logger = logger;

  void setLogging({bool enabled = true, void Function(String message)? logger}) {
    _logging = enabled;
    _logger = logger ?? _logger;
  }

  Future<dynamic> get(
    String pathOrUrl, {
    Map<String, String>? query,
    Map<String, String>? headers,
  }) async {
    return _send(
      method: 'GET',
      pathOrUrl: pathOrUrl,
      query: query,
      headers: headers,
    );
  }

  Future<dynamic> post(
    String pathOrUrl, {
    Map<String, String>? query,
    dynamic data,
    Map<String, String>? headers,
    bool jsonBody = true,
  }) async {
    return _send(
      method: 'POST',
      pathOrUrl: pathOrUrl,
      query: query,
      data: data,
      headers: headers,
      jsonBody: jsonBody,
    );
  }

  Future<dynamic> put(
    String pathOrUrl, {
    Map<String, String>? query,
    dynamic data,
    Map<String, String>? headers,
    bool jsonBody = true,
  }) async {
    return _send(
      method: 'PUT',
      pathOrUrl: pathOrUrl,
      query: query,
      data: data,
      headers: headers,
      jsonBody: jsonBody,
    );
  }

  Future<dynamic> delete(
    String pathOrUrl, {
    Map<String, String>? query,
    dynamic data,
    Map<String, String>? headers,
    bool jsonBody = true,
  }) async {
    return _send(
      method: 'DELETE',
      pathOrUrl: pathOrUrl,
      query: query,
      data: data,
      headers: headers,
      jsonBody: jsonBody,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String pathOrUrl,
    Map<String, String>? query,
    dynamic data,
    Map<String, String>? headers,
    bool jsonBody = true,
  }) async {
    final client = http.Client();
    final sw = Stopwatch()..start();
    try {
      final uri = _buildUri(pathOrUrl, query);
      final reqHeaders = <String, String>{...defaultHeaders, if (headers != null) ...headers};

      void log(String msg) {
        if (!_logging) return;
        final sink = _logger ?? debugPrint;
        sink('[ApiClient] $msg');
      }

      http.Response res;
      final reqInfo = StringBuffer();
      reqInfo.write('${method.toUpperCase()} ${uri.toString()}');
      reqInfo.write(' headers=${jsonEncode(reqHeaders)}');
      if (data != null) {
        final bodyPreview = jsonBody ? jsonEncode(data) : data.toString();
        reqInfo.write(' body=${_truncate(bodyPreview)}');
      }
      log('REQUEST: ${reqInfo.toString()}');
      switch (method) {
        case 'GET':
          res = await client.get(uri, headers: reqHeaders).timeout(timeout);
          break;
        case 'POST':
          final body = _encodeBody(data, jsonBody, reqHeaders);
          res = await client.post(uri, headers: reqHeaders, body: body).timeout(timeout);
          break;
        case 'PUT':
          final body = _encodeBody(data, jsonBody, reqHeaders);
          res = await client.put(uri, headers: reqHeaders, body: body).timeout(timeout);
          break;
        case 'DELETE':
          final body = _encodeBody(data, jsonBody, reqHeaders);
          res = await client.delete(uri, headers: reqHeaders, body: body).timeout(timeout);
          break;
        default:
          throw UnsupportedError('Unsupported method: $method');
      }

      final decoded = _decodeBody(res);
      sw.stop();
      log('RESPONSE: code=${res.statusCode} in ${sw.elapsedMilliseconds}ms body=${_truncate(_safeString(decoded))}');
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return decoded;
      }
      // Normalize error to {status:false, message:...}
      if (decoded is Map && decoded['message'] != null) {
        return decoded;
      }
      return {
        'status': false,
        'message': 'HTTP ${res.statusCode}: ${res.reasonPhrase ?? 'Error'}',
        'code': res.statusCode,
        'data': decoded,
      };
    } on TimeoutException {
      sw.stop();
      return {
        'status': false,
        'message': 'Request timeout',
      };
    } catch (e) {
      sw.stop();
      return {
        'status': false,
        'message': e.toString(),
      };
    } finally {
      client.close();
    }
  }

  Uri _buildUri(String pathOrUrl, Map<String, String>? query) {
    Uri uri;
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      uri = Uri.parse(pathOrUrl);
    } else {
      if (baseUri == null) {
        throw ArgumentError('Relative path provided without baseUri');
      }
      final base = baseUri!;
      uri = base.resolve(pathOrUrl.startsWith('/') ? pathOrUrl.substring(1) : pathOrUrl);
    }
    if (query == null || query.isEmpty) return uri;
    final newQuery = Map<String, String>.from(uri.queryParameters)..addAll(query);
    return uri.replace(queryParameters: newQuery);
  }

  dynamic _decodeBody(http.Response res) {
    if (res.body.isEmpty) return {};
    final contentType = res.headers['content-type'] ?? '';
    final isJson = contentType.contains('application/json') || contentType.contains('text/json') || contentType.contains('application/ld+json');
    if (isJson) {
      try {
        return jsonDecode(res.body);
      } catch (_) {
        // fallthrough to text
      }
    }
    return res.body;
  }

  dynamic _encodeBody(dynamic data, bool jsonBody, Map<String, String> headers) {
    if (data == null) return null;
    if (!jsonBody) return data;
    headers.putIfAbsent('Content-Type', () => 'application/json');
    return jsonEncode(data);
  }

  String _truncate(String s, {int max = 800}) {
    if (s.length <= max) return s;
    return s.substring(0, max) + '...(${s.length} bytes)';
  }

  String _safeString(dynamic body) {
    if (body == null) return 'null';
    if (body is String) return body;
    try {
      return jsonEncode(body);
    } catch (_) {
      return body.toString();
    }
  }
}

