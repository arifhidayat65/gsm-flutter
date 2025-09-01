import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfBuilder {
  static Future<Uint8List> buildFromResponse(dynamic data) async {
    final root = _extractDataMap(data);
    final pajak = _extractPajak(root);

    final doc = pw.Document();

    final primary = const PdfColor.fromInt(0xFF03AC0E);
    final onPrimary = PdfColors.white;
    final muted = PdfColors.grey700;

    final titleStyle = pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: onPrimary);
    final subtitleStyle = pw.TextStyle(fontSize: 10, color: onPrimary);
    final labelStyle = pw.TextStyle(color: muted);
    final tableHeader = pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black);

    final nopol = (root['nopol']?.toString() ?? '-').toUpperCase();
    final merkModel = _join([root['merk'], root['model']]);
    final tahun = root['tahun']?.toString();
    final jatuhTempo = pajak['tglAkhirPkb']?.toString();
    final aktif = pajak['aktif'] == true;
    final totalPajak = _parseNum(pajak['totalPajak']) ?? 0;
    final generatedAt = DateTime.now();
    final ref = _buildRef(generatedAt, nopol);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Row(
            children: [
              pw.Text('Dokumen ini bersifat informasi. Validasi akhir mengikuti sistem resmi.', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
              pw.Spacer(),
              pw.Text('Hal. ${context.pageNumber}/${context.pagesCount}', style: pw.TextStyle(color: PdfColors.grey600, fontSize: 9)),
            ],
          ),
        ),
        build: (ctx) => [
          // Branded header
          _header(primary: primary, onPrimary: onPrimary, aktif: aktif, generatedAt: generatedAt),

          pw.SizedBox(height: 14),

          // Plate banner + Total card
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Plate banner
              pw.Expanded(
                flex: 3,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(8),
                    color: PdfColors.white,
                  ),
                  padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: pw.Center(
                    child: pw.Text(nopol.isEmpty ? '-' : nopol,
                        style: pw.TextStyle(letterSpacing: 2, fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              // Total card
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: const PdfColor.fromInt(0xFFB7E7BA)),
                    color: const PdfColor.fromInt(0xFFEAF8EB),
                  ),
                  padding: const pw.EdgeInsets.all(10),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Total Pajak', style: pw.TextStyle(color: const PdfColor.fromInt(0xFF1E7D25), fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(_formatRupiah(totalPajak), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF0D5C15))),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          // Summary chips
          _summaryChips(merkModel: merkModel, tahun: tahun, jatuhTempo: jatuhTempo, aktif: aktif),

          pw.SizedBox(height: 10),
          // Reference + QR placeholder
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Expanded(child: pw.Text('Kode Referensi: ' + ref, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700))),
              _qrPlaceholder(ref),
            ],
          ),

          pw.SizedBox(height: 16),

          // Rincian pajak table with totals
          _pajakTable(pajak, headerStyle: tableHeader),

          pw.SizedBox(height: 18),
          _notesSection(primary: primary),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header({required PdfColor primary, required PdfColor onPrimary, required bool aktif, required DateTime generatedAt}) {
    final ts = _fmtDateTime(generatedAt);
    return pw.Container(
      decoration: pw.BoxDecoration(color: primary, borderRadius: pw.BorderRadius.circular(10)),
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _brandMark(primary: primary, onPrimary: onPrimary),
          pw.SizedBox(width: 8),
          pw.Container(
            decoration: pw.BoxDecoration(color: onPrimary, borderRadius: pw.BorderRadius.circular(8)),
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: pw.Text('e-pajak', style: pw.TextStyle(color: primary, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Laporan Cek Pajak Kendaraan', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: onPrimary)),
              pw.Text('Dibuat: $ts', style: pw.TextStyle(fontSize: 9, color: onPrimary)),
            ],
          ),
          pw.Spacer(),
          _statusBadge(aktif ? 'AKTIF' : 'NON-AKTIF', active: aktif),
        ],
      ),
    );
  }

  static pw.Widget _brandMark({required PdfColor primary, required PdfColor onPrimary}) {
    return pw.Container(
      width: 26,
      height: 26,
      decoration: pw.BoxDecoration(color: onPrimary, borderRadius: pw.BorderRadius.circular(13)),
      alignment: pw.Alignment.center,
      child: pw.Text('e', style: pw.TextStyle(color: primary, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _summaryChips({String? merkModel, String? tahun, String? jatuhTempo, required bool aktif}) {
    pw.Widget chip(String label, String? value) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey200,
          borderRadius: pw.BorderRadius.circular(16),
        ),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          children: [
            pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
            pw.SizedBox(width: 6),
            pw.Text(value == null || value.isEmpty ? '-' : value, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.black)),
          ],
        ),
      );
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('Merk/Model', merkModel),
        chip('Tahun', tahun),
        chip('Jatuh Tempo', jatuhTempo),
        chip('Status', aktif ? 'Aktif' : 'Non-aktif'),
      ],
    );
  }

  static pw.Widget _kv(String label, String? value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 120, child: pw.Text(label, style: const pw.TextStyle(color: PdfColors.grey700))),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Text(value == null || value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  static pw.Widget _statusBadge(String text, {required bool active}) {
    final bg = active ? PdfColors.green100 : PdfColors.red100;
    final fg = active ? PdfColors.green800 : PdfColors.red800;
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(color: bg, borderRadius: pw.BorderRadius.circular(12)),
      child: pw.Text(text, style: pw.TextStyle(color: fg, fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _pajakTable(Map<String, dynamic> pajak, {required pw.TextStyle headerStyle}) {
    final rows = <pw.TableRow>[];
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFEFEFEF)),
        children: [
          _th('Komponen', headerStyle),
          _th('Pokok', headerStyle, alignRight: true),
          _th('Denda', headerStyle, alignRight: true),
        ],
      ),
    );

    pw.TableRow dataRow(String label, dynamic pokok, dynamic denda, {bool shaded = false}) {
      return pw.TableRow(
        decoration: shaded ? const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF8F8F8)) : null,
        children: [
          _td(label),
          _tdMoney(_parseNum(pokok) ?? 0),
          _tdMoney(_parseNum(denda) ?? 0),
        ],
      );
    }

    final pkbP = _parseNum(pajak['pkbPokok']) ?? 0;
    final pkbD = _parseNum(pajak['pkbDenda']) ?? 0;
    final swdP = _parseNum(pajak['swdklljPokok']) ?? 0;
    final swdD = _parseNum(pajak['swdklljDenda']) ?? 0;
    final opsP = _parseNum(pajak['opsenPokok']) ?? 0;
    final opsD = _parseNum(pajak['opsenDenda']) ?? 0;

    rows.add(dataRow('PKB', pkbP, pkbD));
    rows.add(dataRow('SWDKLLJ', swdP, swdD, shaded: true));
    rows.add(dataRow('Opsen', opsP, opsD));

    final totalPokok = pkbP + swdP + opsP;
    final totalDenda = pkbD + swdD + opsD;
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE3F3E5)),
        children: [
          _th('TOTAL', headerStyle),
          _tdMoney(totalPokok),
          _tdMoney(totalDenda),
        ],
      ),
    );

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: const {
        0: pw.FlexColumnWidth(2),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
      },
      children: rows,
    );
  }

  static pw.Widget _notesSection({required PdfColor primary}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Catatan', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: primary)),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'Nilai pajak merupakan hasil perhitungan sistem dan dapat berubah sesuai kebijakan instansi. '),
          pw.Bullet(text: 'Harap verifikasi kembali sebelum melakukan pembayaran. '),
        ],
      ),
    );
  }

  static pw.Widget _th(String text, pw.TextStyle style, {bool alignRight = false}) =>
      pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Align(alignment: alignRight ? pw.Alignment.centerRight : pw.Alignment.centerLeft, child: pw.Text(text, style: style)));
  static pw.Widget _td(String text) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(text));
  static pw.Widget _tdMoney(num value) => pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(_formatRupiah(value))));

  static Map<String, dynamic> _extractDataMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['data'] is Map<String, dynamic>) return (data['data'] as Map<String, dynamic>);
      return data;
    }
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map<String, dynamic>) return first;
    }
    return <String, dynamic>{};
  }

  static Map<String, dynamic> _extractPajak(Map<String, dynamic> map) {
    final pajak = map['pajak'];
    if (pajak is Map<String, dynamic>) return pajak;
    return <String, dynamic>{};
  }

  static String _join(List<dynamic?> parts) {
    return parts.where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e.toString()).join(' ');
  }

  static num? _parseNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.-]'), '');
      return num.tryParse(cleaned);
    }
    return null;
  }

  static String _formatRupiah(num n) {
    final negative = n < 0;
    var s = n.abs().toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idx = s.length - i;
      buf.write(s[i]);
      if (idx > 1 && idx % 3 == 1) buf.write('.');
    }
    final text = buf.toString();
    return (negative ? '- ' : '') + 'Rp ' + text;
  }

  static String _fmtDateTime(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  static String _buildRef(DateTime dt, String nopol) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = '${dt.year}${two(dt.month)}${two(dt.day)}${two(dt.hour)}${two(dt.minute)}';
    final cleanNopol = nopol.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return 'EPJ-$h-$cleanNopol';
  }

  static pw.Widget _qrPlaceholder(String data) {
    // Placeholder box for QR; replace with actual QR render when available
    return pw.Container(
      width: 64,
      height: 64,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey500),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      alignment: pw.Alignment.center,
      child: pw.Text('QR', style: pw.TextStyle(color: PdfColors.grey600)),
    );
  }
}
