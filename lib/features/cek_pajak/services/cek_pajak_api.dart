import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:apps_pajak/shared/services/api_client.dart';

class CekPajakApi {
  static final _client = ApiClient(
    baseUri: Uri(scheme: 'https', host: 'cekpajak.bystpn.web.id'),
  );

  static void setLogging({bool enabled = true, void Function(String message)? logger}) {
    _client.setLogging(enabled: enabled, logger: logger);
  }
  static Future<dynamic> fetch({
    required String id,
    required String nomorKendaraan,
    String? kodeWilayah,
  }) async {
    final nopol = nomorKendaraan.replaceAll(RegExp(r'\s+'), '').toUpperCase();
    final query = <String, String>{};
    if (kodeWilayah != null && kodeWilayah.trim().isNotEmpty) {
      query['kode_wilayah'] = kodeWilayah.trim();
    }
    return _client.get('/api/$id/$nopol', query: query.isEmpty ? null : query);
  }
}

