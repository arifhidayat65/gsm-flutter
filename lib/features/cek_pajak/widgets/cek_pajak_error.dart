import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CekPajakError extends StatelessWidget {
  final String? message;
  final dynamic payload; // Expecting {"status": false, "message": "..."}
  final VoidCallback? onRetry;
  const CekPajakError({super.key, this.message, this.payload, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final msg = _extractMessage(payload) ?? message ?? 'Terjadi kesalahan';
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        Card(
          color: scheme.errorContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.error_outline, color: scheme.onErrorContainer, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gagal Memuat', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: scheme.onErrorContainer, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(msg, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onErrorContainer)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (onRetry != null)
                            FilledButton.tonalIcon(
                              onPressed: onRetry,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final pretty = const JsonEncoder.withIndent('  ').convert(payload ?? {'message': msg});
                              await Clipboard.setData(ClipboardData(text: pretty));
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Detail error disalin')));
                              }
                            },
                            icon: const Icon(Icons.copy_all),
                            label: const Text('Salin Detail'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (payload is Map && payload.isNotEmpty) ...[
          _ErrorsList(payload: payload),
          const SizedBox(height: 12),
          _TechDetails(payload: payload),
          const SizedBox(height: 12),
          _Details(payload: payload),
        ],
      ],
    );
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map) {
      // Sesuai response.json
      final msg = payload['message'];
      if (msg != null) return msg.toString();
    }
    return null;
  }
}

class _ErrorsList extends StatelessWidget {
  final Map payload;
  const _ErrorsList({required this.payload});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final errors = _extractErrors(payload.cast<String, dynamic>());
    if (errors.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Kesalahan', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final e in errors)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: scheme.onSurface))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _extractErrors(Map<String, dynamic> map) {
    final out = <String>[];
    final v = map['errors'] ?? map['error'] ?? map['validation'];
    if (v is String) out.add(v);
    if (v is List) {
      for (final item in v) {
        out.add(item.toString());
      }
    }
    if (v is Map) {
      for (final entry in v.entries) {
        final key = entry.key.toString();
        final val = entry.value;
        if (val is List) {
          for (final item in val) {
            out.add('$key: ${item.toString()}');
          }
        } else {
          out.add('$key: ${val.toString()}');
        }
      }
    }
    return out;
  }
}

class _TechDetails extends StatelessWidget {
  final Map payload;
  const _TechDetails({required this.payload});
  @override
  Widget build(BuildContext context) {
    final map = payload.cast<String, dynamic>();
    final candidates = <String, String?>{
      'Status': map['status']?.toString(),
      'Code': map['code']?.toString(),
      'Path': _findFirstString(map, ['path','endpoint','url']),
      'Method': _findFirstString(map, ['method']),
      'Timestamp': _findFirstString(map, ['timestamp','time','ts','date']),
      'Request ID': _findFirstString(map, ['request_id','req_id','x_request_id']),
      'Trace ID': _findFirstString(map, ['trace_id','traceid','trace']),
      'Duration': _findFirstString(map, ['duration','elapsed','latency']),
      'Server': _findFirstString(map, ['server','host']),
      'Environment': _findFirstString(map, ['env','environment','stage']),
    };
    final entries = candidates.entries.where((e) => e.value != null && e.value!.isNotEmpty).toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Teknis', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final e in entries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 140, child: Text(e.key, style: Theme.of(context).textTheme.labelMedium)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value!)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

String? _findFirstString(Map<String, dynamic> map, List<String> keys) {
  for (final k in map.keys) {
    final nk = k.toLowerCase();
    for (final want in keys) {
      if (nk == want.toLowerCase()) return map[k]?.toString();
    }
  }
  // also search in nested maps commonly named 'meta' or 'debug'
  for (final container in ['meta','debug','detail_teknis','backend']) {
    final v = map[container];
    if (v is Map<String, dynamic>) {
      final found = _findFirstString(v, keys);
      if (found != null) return found;
    }
  }
  return null;
}

class _Details extends StatefulWidget {
  final dynamic payload;
  const _Details({required this.payload});
  @override
  State<_Details> createState() => _DetailsState();
}

class _DetailsState extends State<_Details> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(widget.payload);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              title: const Text('Detail Teknis'),
              trailing: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onTap: () => setState(() => _expanded = !_expanded),
            ),
            AnimatedCrossFade(
              crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 200),
              firstChild: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: SelectableText(pretty, style: Theme.of(context).textTheme.bodySmall),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

