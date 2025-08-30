import 'package:flutter/material.dart';

class CekPajakResult extends StatelessWidget {
  final dynamic data;
  const CekPajakResult({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      return const SizedBox.shrink();
    }

    if (data is List) {
      final list = data.cast<dynamic>();
      if (list.isEmpty) {
        return _EmptyState(message: 'Tidak ada data');
      }
      return ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemBuilder: (context, i) {
          final item = list[i];
          if (item is Map) {
            return _VehicleCard(map: item.cast<String, dynamic>());
          }
          return _GenericTile(value: item);
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: list.length,
      );
    }

    if (data is Map) {
      final map = (data as Map).cast<String, dynamic>();
      final hasStatus = map.containsKey('status');
      final statusIsTrue = hasStatus && (map['status'] == true || (map['status'] is String && map['status'].toString().toLowerCase() == 'true'));
      final statusIsFalse = hasStatus && (map['status'] == false || (map['status'] is String && map['status'].toString().toLowerCase() == 'false'));
      if (statusIsFalse) {
        // Error seharusnya ditangani di CekPajakError sebelum sampai sini
        return _EmptyState(message: map['message']?.toString() ?? 'Terjadi kesalahan');
      }
      if (statusIsTrue) {
        final inner = map['data'];
        if (inner is List) {
          if (inner.isEmpty) return const _EmptyState(message: 'Tidak ada data');
          final list = inner.cast<dynamic>();
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 24),
            itemBuilder: (context, i) {
              final item = list[i];
              if (item is Map) {
                return _VehicleCard(map: item.cast<String, dynamic>());
              }
              return _GenericTile(value: item);
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: list.length,
          );
        }
        if (inner is Map) {
          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _VehicleCard(map: inner.cast<String, dynamic>()),
              _TechDetailsBlock(root: map),
            ],
          );
        }
        // Jika tidak ada data, tampilkan pesan sukses + render map top-level
        final msg = map['message']?.toString();
        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (msg != null && msg.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _SuccessInfo(message: msg),
              ),
            _VehicleCard(map: map),
            _TechDetailsBlock(root: map),
          ],
        );
      }
      // Tidak menggunakan pembungkus status/data -> render langsung
      return ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _VehicleCard(map: map),
          _TechDetailsBlock(root: map),
        ],
      );
    }

    return _GenericTile(value: data);
  }
}

class _VehicleCard extends StatelessWidget {
  final Map<String, dynamic> map;
  const _VehicleCard({required this.map});

  @override
  Widget build(BuildContext context) {
    final plate = _findFirst(map, ['nopol', 'plat', 'polisi', 'nomor_kendaraan', 'no_polisi']);
    final owner = _findFirst(map, ['nama', 'nama_pemilik', 'pemilik']);
    final address = _findFirst(map, ['alamat']);
    final brand = _findFirst(map, ['merk', 'merek', 'brand']);
    final model = _findFirst(map, ['tipe', 'model', 'jenis']);
    final year = _findFirst(map, ['tahun', 'tahun_pembuatan', 'tahun_rakit']);
    final color = _findFirst(map, ['warna']);
    final berlaku = _findFirst(map, ['berlaku', 'masa_berlaku', 'berlaku_sd', 'berlaku_sampai']);
    String? due = _findFirst(map, ['jatuh_tempo', 'due_date']);
    String status = (_findFirst(map, ['status', 'status_pajak']) ?? '').toString();
    num? total = _firstNumber(map, ['total', 'total_pkb', 'pkb', 'nominal', 'jumlah', 'tunggakan', 'pajak', 'total_pajak']);

    Map<String, dynamic>? pajak;
    final pj = map['pajak'];
    if (pj is Map) {
      pajak = pj.cast<String, dynamic>();
      // prefer nested total
      final t = pajak['totalPajak'] ?? pajak['total_pajak'];
      final numParsed = _parseNum(t);
      if (numParsed != null) total = numParsed;
      // due and status from nested
      due ??= pajak['tglAkhirPkb']?.toString();
      if (status.isEmpty && pajak['aktif'] is bool) {
        status = (pajak['aktif'] as bool) ? 'aktif' : 'tidak aktif';
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlateHeader(plate: plate?.toString() ?? '-'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (owner != null || address != null)
                  _Section(
                    title: 'Pemilik',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (owner != null)
                          Text(owner.toString(), style: Theme.of(context).textTheme.titleMedium),
                        if (address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(address.toString(), style: Theme.of(context).textTheme.bodyMedium),
                          ),
                      ],
                    ),
                  ),
                _Section(
                  title: 'Kendaraan',
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoTile(label: 'Merk', value: _join([brand, model])),
                      _InfoTile(label: 'Tahun', value: year?.toString()),
                      _InfoTile(label: 'Warna', value: color?.toString()),
                    ],
                  ),
                ),
                _Section(
                  title: 'Status Pajak',
                  child: Row(
                    children: [
                      _StatusBadge(text: status.isNotEmpty ? status : (due ?? berlaku ?? '-').toString()),
                      const Spacer(),
                      if (total != null)
                        _AmountBox(amount: total),
                    ],
                  ),
                ),
                if (pajak != null) _PajakDetails(pajak: pajak),
                _Section(
                  title: 'Detail Lainnya',
                  child: _RemainingDetails(map: map, excludeKeys: _normalizedKeysUsed),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static final Set<String> _normalizedKeysUsed = {
    'nopol','plat','polisi','nomor_kendaraan','no_polisi',
    'nama','nama_pemilik','pemilik','alamat','merk','merek','brand','tipe','model','jenis',
    'tahun','tahun_pembuatan','tahun_rakit','warna','berlaku','masa_berlaku','berlaku_sd','berlaku_sampai',
    'jatuh_tempo','due_date','status','status_pajak','message','data','total','total_pkb','pkb','nominal','jumlah','tunggakan','pajak','total_pajak',
    'meta','debug','detail_teknis','backend','request','response'
  };
}

class _PlateHeader extends StatelessWidget {
  final String plate;
  const _PlateHeader({required this.plate});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        children: [
          Icon(Icons.directions_car_filled, color: scheme.onPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              plate.isEmpty ? '-' : plate,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String? value;
  const _InfoTile({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value == null || value!.isEmpty ? '-' : value!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  const _StatusBadge({required this.text});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isOk = _containsAny(text, ['lunas', 'aktif', 'valid']);
    final bg = isOk ? scheme.secondaryContainer : scheme.errorContainer;
    final fg = isOk ? scheme.onSecondaryContainer : scheme.onErrorContainer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOk ? Icons.verified : Icons.error_outline, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(text.isEmpty ? '-' : text, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  final num amount;
  const _AmountBox({required this.amount});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Total Pajak', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(_formatRupiah(amount), style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RemainingDetails extends StatelessWidget {
  final Map<String, dynamic> map;
  final Set<String> excludeKeys;
  const _RemainingDetails({required this.map, required this.excludeKeys});
  @override
  Widget build(BuildContext context) {
    final items = <MapEntry<String, dynamic>>[];
    map.forEach((k, v) {
      if (!excludeKeys.contains(_norm(k))) {
        items.add(MapEntry(k, v));
      }
    });
    items.sort((a, b) => a.key.compareTo(b.key));
    return Column(
      children: [
        for (final e in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 140,
                  child: Text(_labelize(e.key), style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                const SizedBox(width: 8),
                Expanded(child: _ValueView(value: e.value)),
              ],
            ),
          ),
      ],
    );
  }
}

class _ValueView extends StatelessWidget {
  final dynamic value;
  const _ValueView({required this.value});
  @override
  Widget build(BuildContext context) {
    if (value == null) return const Text('-');
    if (value is num) return Text(_formatRupiahIfMoney(value));
    if (value is bool) return Text(value ? 'Ya' : 'Tidak');
    if (value is List) {
      if (value.isEmpty) return const Text('-');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [for (final v in value) Text(v.toString())],
      );
    }
    if (value is Map) {
      if (value.isEmpty) return const Text('-');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: value.entries.map((e) => Text('${_labelize(e.key)}: ${e.value}')).toList(),
      );
    }
    return Text(value.toString());
  }
}

class _GenericTile extends StatelessWidget {
  final dynamic value;
  const _GenericTile({required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(value.toString()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(message),
        ],
      ),
    );
  }
}

class _SuccessInfo extends StatelessWidget {
  final String message;
  const _SuccessInfo({required this.message});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline, color: scheme.onSecondaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PajakDetails extends StatelessWidget {
  final Map<String, dynamic> pajak;
  const _PajakDetails({required this.pajak});
  @override
  Widget build(BuildContext context) {
    num? pkbPokok = _parseNum(pajak['pkbPokok']);
    num? pkbDenda = _parseNum(pajak['pkbDenda']);
    num? swdPokok = _parseNum(pajak['swdklljPokok']);
    num? swdDenda = _parseNum(pajak['swdklljDenda']);
    num? opsenPokok = _parseNum(pajak['opsenPokok']);
    num? opsenDenda = _parseNum(pajak['opsenDenda']);
    final due = pajak['tglAkhirPkb']?.toString();
    final aktif = pajak['aktif'];

    return _Section(
      title: 'Rincian Pajak',
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoTile(label: 'PKB', value: _sumToString(pkbPokok, pkbDenda)),
              _InfoTile(label: 'SWDKLLJ', value: _sumToString(swdPokok, swdDenda)),
              _InfoTile(label: 'Opsen', value: _sumToString(opsenPokok, opsenDenda)),
              if (due != null) _InfoTile(label: 'Jatuh Tempo', value: due),
              if (aktif is bool) _InfoTile(label: 'Status', value: aktif ? 'Aktif' : 'Non-aktif'),
            ],
          ),
        ],
      ),
    );
  }

  String? _sumToString(num? pokok, num? denda) {
    if (pokok == null && denda == null) return null;
    final total = (pokok ?? 0) + (denda ?? 0);
    return _formatRupiah(total);
  }
}

class _TechDetailsBlock extends StatelessWidget {
  final Map<String, dynamic> root;
  const _TechDetailsBlock({required this.root});
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? details;
    for (final key in const ['detail_teknis','meta','debug','backend']) {
      final v = root[key];
      if (v is Map<String, dynamic> && v.isNotEmpty) {
        details = v;
        break;
      }
    }
    if (details == null || details.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Teknis Backend', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              _RemainingDetails(map: details!, excludeKeys: const {}),
            ],
          ),
        ),
      ),
    );
  }
}

// Helpers
String? _findFirst(Map<String, dynamic> map, List<String> keys) {
  for (final k in map.keys) {
    final nk = _norm(k);
    for (final want in keys) {
      if (nk == _norm(want)) return map[k]?.toString();
    }
  }
  return null;
}

num? _firstNumber(Map<String, dynamic> map, List<String> keys) {
  final s = _findFirst(map, keys);
  if (s == null) return null;
  final cleaned = s.replaceAll(RegExp(r'[^0-9.-]'), '');
  return num.tryParse(cleaned);
}

String _norm(String s) => s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

bool _containsAny(String text, List<String> pats) {
  final t = text.toLowerCase();
  return pats.any((p) => t.contains(p));
}

String _join(List<dynamic?> parts) {
  return parts.where((e) => e != null && e.toString().trim().isNotEmpty).map((e) => e.toString()).join(' ');
}

String _labelize(String key) {
  final parts = key.replaceAll('_', ' ').replaceAll('-', ' ').split(' ');
  return parts.map((p) => p.isEmpty ? p : (p[0].toUpperCase() + p.substring(1).toLowerCase())).join(' ');
}

String _formatRupiahIfMoney(num n) {
  if (n >= 1000) return _formatRupiah(n);
  return n.toString();
}

String _formatRupiah(num n) {
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

num? _parseNum(dynamic v) {
  if (v == null) return null;
  if (v is num) return v;
  if (v is String) {
    final cleaned = v.replaceAll(RegExp(r'[^0-9.-]'), '');
    return num.tryParse(cleaned);
  }
  return null;
}

