import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:apps_pajak/features/cek_pajak/services/pdf_builder.dart';

class PdfPreviewPage extends StatelessWidget {
  final dynamic data;
  final String filename;
  const PdfPreviewPage({super.key, required this.data, required this.filename});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pratinjau PDF'),
      ),
      body: PdfPreview(
        build: (format) => PdfBuilder.buildFromResponse(data),
        pdfFileName: filename,
        allowSharing: true,
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}

