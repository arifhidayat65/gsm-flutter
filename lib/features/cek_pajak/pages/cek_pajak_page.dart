import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:apps_pajak/features/cek_pajak/providers/cek_pajak_provider.dart';
import 'package:apps_pajak/features/cek_pajak/services/pdf_builder.dart';
import 'package:apps_pajak/shared/services/file_saver.dart';
import 'package:printing/printing.dart';
import 'package:open_filex/open_filex.dart';
import 'package:apps_pajak/features/cek_pajak/pages/pdf_preview_page.dart';
import 'package:apps_pajak/features/cek_pajak/widgets/cek_pajak_result.dart';
import 'package:apps_pajak/features/cek_pajak/widgets/cek_pajak_error.dart';
import 'package:apps_pajak/shared/widgets/section_card.dart';
import 'package:apps_pajak/features/cek_pajak/data/provinsi.dart';
import 'package:apps_pajak/theme.dart';

class CekPajakPage extends StatefulWidget {
  const CekPajakPage({super.key});

  @override
  State<CekPajakPage> createState() => _CekPajakPageState();
}

class _CekPajakPageState extends State<CekPajakPage> {
  final _nopolCtrl = TextEditingController();
  final _kodeWilayahCtrl = TextEditingController();
  String? _selectedProvinsi = 'JABAR'; // default selection
  String _selectedMenu = 'ringkasan';
  static bool _adShownThisSession = false;

  @override
  void initState() {
    super.initState();
    _nopolCtrl.addListener(() => setState(() {}));
    _kodeWilayahCtrl.addListener(() => setState(() {}));
    // Prefill kode wilayah based on default province
    final opt = provinsiOptions.firstWhere(
      (e) => e.key == _selectedProvinsi,
      orElse: () => const ProvinsiOption('', '', '', ''),
    );
    if (opt.key.isNotEmpty) {
      _kodeWilayahCtrl.text = opt.defaultKodeWilayah;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_adShownThisSession && mounted) {
        _adShownThisSession = true;
        _showLaunchAd(context);
      }
    });
  }

  void _submit() {
    final id = (() {
      final key = (_selectedProvinsi ?? '').trim();
      final found = provinsiOptions.firstWhere(
        (e) => e.key == key,
        orElse: () => const ProvinsiOption('', '', '', ''),
      );
      return found.apiId.trim();
    })();
    final nopol = _nopolCtrl.text.trim();
    if (id.isEmpty || nopol.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi Provinsi dan Nomor Kendaraan')),
      );
      return;
    }
    final kode = _kodeWilayahCtrl.text.trim().toUpperCase();
    context.read<CekPajakProvider>().fetch(
      id: id,
      nomorKendaraan: nopol,
      kodeWilayah: kode.isEmpty ? null : kode,
    );
  }

  @override
  void dispose() {
    _nopolCtrl.dispose();
    _kodeWilayahCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Builder(builder: (context) {
          final scheme = Theme.of(context).colorScheme;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long, color: scheme.primary),
              const SizedBox(width: 8),
              const Text('Cek Pajak Kendaraan'),
            ],
          );
        }),
      ),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Consumer<CekPajakProvider>(
              builder: (context, vm, _) {
                return RefreshIndicator(
                  onRefresh: () async => vm.refetch(),
                  child: CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: Builder(builder: (context) {
                            final textTheme = Theme.of(context).textTheme;
                            final scheme = Theme.of(context).colorScheme;
                            return Container(
                              decoration: BoxDecoration(
                                gradient: AppBrand.headerGradient,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Cek Pajak Kendaraan',
                                          style: textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Periksa status pajak kendaraan bermotor Anda',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withOpacity(0.95),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        sliver: SliverToBoxAdapter(
                          child: SectionCard(
                            title: 'Data Kendaraan',
                            child: Column(
                              children: [
                                DropdownButtonFormField<String?>(
                                  value: _selectedProvinsi,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: 'PROVINSI',
                                    border: const OutlineInputBorder(),
                                    prefixIcon: Icon(
                                      Icons.map_outlined,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text('Pilih Provinsi'),
                                    ),
                                    ...provinsiOptions.map(
                                      (e) => DropdownMenuItem<String?>(
                                        value: e.key,
                                        child: Text('${e.name} (${e.apiId})'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    setState(() {
                                      _selectedProvinsi = v;
                                      final opt = provinsiOptions.firstWhere(
                                        (e) => e.key == v,
                                        orElse: () => const ProvinsiOption('', '', '', ''),
                                      );
                                      if (opt.key.isNotEmpty) {
                                        _kodeWilayahCtrl.text = opt.defaultKodeWilayah;
                                        _kodeWilayahCtrl.selection = TextSelection.collapsed(offset: _kodeWilayahCtrl.text.length);
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(height: 12),
                                const SizedBox.shrink(),
                                const SizedBox(height: 12),
                                _NopolField(controller: _nopolCtrl, onSubmit: _submit),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    onPressed: _submit,
                                    icon: const Icon(Icons.search),
                                    label: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Text('Cek'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SectionCard(
                            padding: EdgeInsets.zero,
                            expand: true,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                  child: Row(
                                    children: [
                                      const Spacer(),
                                      OutlinedButton.icon(
                                        onPressed: !(vm.data != null && vm.error == null && vm.loading == false)
                                            ? null
                                            : () {
                                                final nopol = _extractNopol(vm.data);
                                                final ts = _timestampString();
                                                final name = nopol != null && nopol.isNotEmpty
                                                    ? 'cek_pajak_${nopol}_$ts.pdf'
                                                    : 'cek_pajak_$ts.pdf';
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (_) => PdfPreviewPage(data: vm.data, filename: name),
                                                  ),
                                                );
                                              },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                        icon: Icon(Icons.preview_outlined, color: Theme.of(context).colorScheme.primary),
                                        label: const Text('Pratinjau'),
                                      ),
                                      const SizedBox(width: 8),
                                      FilledButton.icon(
                                        onPressed: !(vm.data != null && vm.error == null && vm.loading == false)
                                            ? null
                                            : () async {
                                                try {
                                                  final bytes = await PdfBuilder.buildFromResponse(vm.data);
                                                  final nopol = _extractNopol(vm.data);
                                                  final ts = _timestampString();
                                                  final name = nopol != null && nopol.isNotEmpty
                                                      ? 'cek_pajak_${nopol}_$ts.pdf'
                                                      : 'cek_pajak_$ts.pdf';
                                                  final file = await FileSaverService.savePdfToDownloads(bytes: bytes, filename: name);
                                                  if (file.path.isEmpty) {
                                                    await Printing.sharePdf(bytes: bytes, filename: name);
                                                    if (context.mounted) {
                                                      ScaffoldMessenger.of(context).showSnackBar(
                                                        const SnackBar(content: Text('Membuka opsi bagi/simpan PDF')),
                                                      );
                                                    }
                                                  } else {
                                                    try {
                                                      final p = file.path;
                                                      final isContentUri = p.startsWith('content://');
                                                      final exists = !isContentUri && File(p).existsSync();
                                                      if (!exists) {
                                                        await Printing.sharePdf(bytes: bytes, filename: name);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            const SnackBar(content: Text('Tidak dapat membuka langsung; tampilkan opsi bagi/simpan')),
                                                          );
                                                        }
                                                        return;
                                                      }
                                                      final result = await OpenFilex.open(p);
                                                      if (result.type != ResultType.done) {
                                                        await Printing.sharePdf(bytes: bytes, filename: name);
                                                      } else {
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(content: Text('Tersimpan dan dibuka: ${file.path}')),
                                                          );
                                                        }
                                                      }
                                                    } catch (_) {
                                                      await Printing.sharePdf(bytes: bytes, filename: name);
                                                    }
                                                  }
                                                } catch (e) {
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text('Gagal membuat PDF: $e')),
                                                    );
                                                  }
                                                }
                                              },
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Theme.of(context).colorScheme.primary,
                                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                        icon: const Icon(Icons.picture_as_pdf),
                                        label: const Text('Cetak PDF'),
                                      ),
                                    ],
                                  ),
                                ),
                                if (vm.data != null && vm.error == null && vm.loading == false)
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                                    child: Builder(builder: (context) {
                                      final data = vm.data;
                                      final hasPajak = _hasPajak(data);
                                      final items = <ButtonSegment<String>>[
                                        const ButtonSegment(value: 'ringkasan', label: Text('Ringkasan'), icon: Icon(Icons.dashboard_customize_outlined)),
                                        if (hasPajak) const ButtonSegment(value: 'rincian', label: Text('Rincian Pajak'), icon: Icon(Icons.receipt_long)),
                                      ];
                                      if (!items.any((e) => e.value == _selectedMenu)) {
                                        _selectedMenu = 'ringkasan';
                                      }
                                      return SegmentedButton<String>(
                                        segments: items,
                                        selected: {_selectedMenu},
                                        showSelectedIcon: false,
                                        style: ButtonStyle(
                                          visualDensity: VisualDensity.compact,
                                        ),
                                        onSelectionChanged: (s) {
                                          setState(() {
                                            _selectedMenu = s.first;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 200),
                                      child: Builder(
                                        key: ValueKey('${vm.loading}-${vm.error}-${vm.data.hashCode}'),
                                        builder: (_) {
                                          if (vm.loading) {
                                            return const Center(child: CircularProgressIndicator.adaptive());
                                          }
                                          if (vm.error != null) {
                                            return CekPajakError(
                                              message: vm.error,
                                              payload: vm.errorPayload,
                                              onRetry: vm.refetch,
                                            );
                                          }
                                          if (vm.data == null) {
                                            return ListView(
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              padding: const EdgeInsets.symmetric(vertical: 24),
                                              children: const [
                                                Center(child: Icon(Icons.assignment_outlined, size: 48, color: Colors.grey)),
                                                SizedBox(height: 12),
                                                Center(child: Text('Masukkan data lalu tekan Cek')),
                                              ],
                                            );
                                          }
                                          if (_selectedMenu == 'rincian' && _hasPajak(vm.data)) {
                                            return _PajakRingkasView(data: vm.data);
                                          }
                                          return CekPajakResult(data: vm.data);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

void _showLaunchAd(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'promo',
    barrierColor: Colors.black.withOpacity(0.3),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, a1, a2) {
      return Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(gradient: AppBrand.headerGradient),
            child: Stack(
              children: [
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            padding: const EdgeInsets.all(24),
                            child: const Icon(Icons.directions_car_filled, color: Colors.white, size: 40),
                          ),
                          const SizedBox(width: 18),
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            padding: const EdgeInsets.all(24),
                            child: const Icon(Icons.two_wheeler, color: Colors.white, size: 40),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Cek kendaraan mobil dan motor anda di e-pajak',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Mudah, cepat, dan informatif. Mulai cek status pajak kendaraan Anda sekarang!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: scheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          icon: const Icon(Icons.search),
                          label: const Text('Mulai Cek'),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Nanti saja', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(position: Tween(begin: const Offset(0, 0.05), end: Offset.zero).animate(curved), child: child),
      );
    },
  );
}

class _NopolField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _NopolField({required this.controller, required this.onSubmit});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Nomor Kendaraan',
        hintText: 'contoh: B1234ABC',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(
          Icons.directions_car_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: Icon(Icons.close, color: Theme.of(context).colorScheme.error),
                onPressed: () {
                  controller.clear();
                },
              ),
      ),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSubmit(),
    );
  }
}

String? _extractNopol(dynamic data) {
  try {
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      if (map['data'] is Map) {
        final d = (map['data'] as Map).cast<String, dynamic>();
        final v = d['nopol']?.toString();
        return _sanitizeFilenamePart(v);
      }
      final v = map['nopol']?.toString();
      return _sanitizeFilenamePart(v);
    }
  } catch (_) {}
  return null;
}

String _sanitizeFilenamePart(String? s) {
  if (s == null) return '';
  final compact = s.replaceAll(RegExp(r'\s+'), '');
  return compact.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '');
}

String _timestampString() {
  final now = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  final y = now.year.toString();
  final m = two(now.month);
  final d = two(now.day);
  final hh = two(now.hour);
  final mm = two(now.minute);
  return '${y}${m}${d}_${hh}${mm}';
}

bool _hasPajak(dynamic data) {
  try {
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      final root = map['data'] is Map ? (map['data'] as Map).cast<String, dynamic>() : map;
      return root['pajak'] is Map && (root['pajak'] as Map).isNotEmpty;
    }
  } catch (_) {}
  return false;
}

class _PajakRingkasView extends StatelessWidget {
  final dynamic data;
  const _PajakRingkasView({required this.data});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final root = _extractRoot(data);
    final pajak = (root['pajak'] as Map).cast<String, dynamic>();

    num? pkbPokok = _parseNumD(pajak['pkbPokok']);
    num? pkbDenda = _parseNumD(pajak['pkbDenda']);
    num? swdPokok = _parseNumD(pajak['swdklljPokok']);
    num? swdDenda = _parseNumD(pajak['swdklljDenda']);
    num? opsenPokok = _parseNumD(pajak['opsenPokok']);
    num? opsenDenda = _parseNumD(pajak['opsenDenda']);
    num total = _parseNumD(pajak['totalPajak']) ?? 0;
    final due = pajak['tglAkhirPkb']?.toString();
    final aktif = pajak['aktif'] == true;

    Widget chip(String label, IconData icon) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: scheme.onSecondaryContainer), const SizedBox(width: 6), Text(label, style: TextStyle(color: scheme.onSecondaryContainer))]),
        );

    Widget money(String label, num? val) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 4),
              Text(_formatRupiahD(val ?? 0), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Row(children: [
          _statusBadgeView(aktif, scheme),
          const SizedBox(width: 8),
          if (due != null && due.isNotEmpty) chip('Jatuh Tempo: $due', Icons.event),
          const Spacer(),
          chip('Total: ' + _formatRupiahD(total), Icons.payments_outlined),
        ]),
        const SizedBox(height: 12),
        Row(children: [money('PKB Pokok', pkbPokok), const SizedBox(width: 12), money('PKB Denda', pkbDenda)]),
        const SizedBox(height: 12),
        Row(children: [money('SWDKLLJ Pokok', swdPokok), const SizedBox(width: 12), money('SWDKLLJ Denda', swdDenda)]),
        const SizedBox(height: 12),
        Row(children: [money('Opsen Pokok', opsenPokok), const SizedBox(width: 12), money('Opsen Denda', opsenDenda)]),
      ],
    );
  }

  Map<String, dynamic> _extractRoot(dynamic data) {
    if (data is Map) {
      final map = data.cast<String, dynamic>();
      if (map['data'] is Map) return (map['data'] as Map).cast<String, dynamic>();
      return map;
    }
    if (data is List && data.isNotEmpty && data.first is Map) return (data.first as Map).cast<String, dynamic>();
    return <String, dynamic>{};
  }

  static num? _parseNumD(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.-]'), '');
      return num.tryParse(cleaned);
    }
    return null;
  }

  static String _formatRupiahD(num n) {
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

  Widget _statusBadgeView(bool active, ColorScheme scheme) {
    final bg = active ? scheme.secondaryContainer : scheme.errorContainer;
    final fg = active ? scheme.onSecondaryContainer : scheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(active ? Icons.verified : Icons.error_outline, size: 16, color: fg),
        const SizedBox(width: 6),
        Text(active ? 'Aktif' : 'Non-aktif', style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}


