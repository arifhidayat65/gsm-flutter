import 'package:flutter/foundation.dart';
import 'package:apps_pajak/features/cek_pajak/services/cek_pajak_api.dart';

class CekPajakProvider extends ChangeNotifier {
  bool _loading = false;
  dynamic _data;
  String? _error;
  dynamic _errorPayload;
  String? _lastId;
  String? _lastNopol;
  String? _lastKodeWilayah;

  bool get loading => _loading;
  dynamic get data => _data;
  String? get error => _error;
  dynamic get errorPayload => _errorPayload;
  String? get lastId => _lastId;
  String? get lastNopol => _lastNopol;
  String? get lastKodeWilayah => _lastKodeWilayah;

  // Logging UI removed per request

  Future<void> fetch({required String id, required String nomorKendaraan, String? kodeWilayah}) async {
    _loading = true;
    _error = null;
    _errorPayload = null;
    notifyListeners();
    _lastId = id;
    _lastNopol = nomorKendaraan;
    _lastKodeWilayah = kodeWilayah;
    try {
      final res = await CekPajakApi.fetch(id: id, nomorKendaraan: nomorKendaraan, kodeWilayah: kodeWilayah);
      // Tangani format error sesuai response.json {"status": false, "message": "..."}
      if (res is Map) {
        final status = res['status'];
        final isError = (status is bool && status == false) || (status is String && status.toLowerCase() == 'false');
        if (isError) {
          _error = (res['message'] ?? 'Terjadi kesalahan').toString();
          _errorPayload = res;
          _data = null;
        } else {
          _data = res;
          _error = null;
          _errorPayload = null;
        }
      } else {
        _data = res;
      }
    } catch (e) {
      _error = e.toString();
      _data = null;
      _errorPayload = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refetch() async {
    final id = _lastId;
    final nopol = _lastNopol;
    final kode = _lastKodeWilayah;
    if (id == null || nopol == null) return;
    await fetch(id: id, nomorKendaraan: nopol, kodeWilayah: kode);
  }

  void clear() {
    _data = null;
    _error = null;
    _errorPayload = null;
    _loading = false;
    notifyListeners();
  }
}

