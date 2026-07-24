import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../providers/provider_profile_provider.dart';

class _EditPriceEntry {
  String? pricingUnitId;
  String? existingContractTypeId;
  bool existingPlusMaterial;
  final TextEditingController priceController;
  final TextEditingController priceWithMaterialController;
  bool hasMaterial;

  _EditPriceEntry({
    this.pricingUnitId,
    this.existingContractTypeId,
    this.existingPlusMaterial = false,
    String price = '',
    String priceWithMaterial = '',
    this.hasMaterial = false,
  })  : priceController = TextEditingController(text: price),
        priceWithMaterialController =
            TextEditingController(text: priceWithMaterial);

  void dispose() {
    priceController.dispose();
    priceWithMaterialController.dispose();
  }
}

class ProviderServicesEditScreen extends ConsumerStatefulWidget {
  const ProviderServicesEditScreen({super.key});

  @override
  ConsumerState<ProviderServicesEditScreen> createState() =>
      _ProviderServicesEditScreenState();
}

class _ProviderServicesEditScreenState
    extends ConsumerState<ProviderServicesEditScreen> {
  final _dio = ApiClient().dio;
  bool _loading = true;
  bool _saving = false;

  List<Map<String, dynamic>> _services = [];
  final Map<String, TextEditingController> _descControllers = {};
  final Map<String, List<_EditPriceEntry>> _servicePriceEntries = {};
  final Map<String, List<Map<String, dynamic>>> _validUnitsPerService = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (final c in _descControllers.values) {
      c.dispose();
    }
    for (final entries in _servicePriceEntries.values) {
      for (final e in entries) {
        e.dispose();
      }
    }
    super.dispose();
  }

  String _formatPrice(dynamic value) {
    if (value == null) return '';
    if (value is num) return value.toInt().toString();
    final parsed = double.tryParse(value.toString());
    if (parsed != null) return parsed.toInt().toString();
    return value.toString();
  }

  Future<void> _loadData() async {
    try {
      final servicesRes = await _dio.get(ApiEndpoints.providerServices);

      final services = (servicesRes.data['data'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];

      for (final svc in services) {
        final svcId = svc['id'] as String;
        _descControllers[svcId] =
            TextEditingController(text: svc['description'] as String? ?? '');

        final validUnits = (svc['services']?['service_pricing_units'] as List?)
                ?.map((spu) => spu['pricing_units'] as Map<String, dynamic>)
                .toList() ??
            [];
        _validUnitsPerService[svcId] = validUnits;

        final existingPrices = svc['provider_service_prices'] as List? ?? [];
        final entries = <_EditPriceEntry>[];

        for (final ep in existingPrices) {
          final puId = ep['pricing_unit_id'] as String?;
          final puData =
              validUnits.where((u) => u['id'] == puId).toList();
          entries.add(_EditPriceEntry(
            pricingUnitId: puId,
            existingContractTypeId: ep['contract_type_id'] as String?,
            existingPlusMaterial: ep['plus_material'] == true,
            price: _formatPrice(ep['price']),
            priceWithMaterial: _formatPrice(ep['price_with_material']),
            hasMaterial:
                puData.isNotEmpty && puData.first['has_material'] == true,
          ));
        }

        if (entries.isEmpty) {
          entries.add(_EditPriceEntry());
        }

        _servicePriceEntries[svcId] = entries;
      }

      if (mounted) {
        setState(() {
          _services = services;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Gagal memuat data: ${ApiClient.errorMessage(e)}')),
        );
      }
    }
  }

  Map<String, dynamic>? _findUnit(
      List<Map<String, dynamic>> validUnits, String? unitId) {
    if (unitId == null) return null;
    for (final u in validUnits) {
      if (u['id'] == unitId) return u;
    }
    return null;
  }

  void _addPriceEntry(String svcId) {
    setState(() {
      _servicePriceEntries[svcId]!.add(_EditPriceEntry());
    });
  }

  void _removePriceEntry(String svcId, int index) {
    setState(() {
      final entries = _servicePriceEntries[svcId]!;
      entries[index].dispose();
      entries.removeAt(index);
      if (entries.isEmpty) {
        entries.add(_EditPriceEntry());
      }
    });
  }

  Future<void> _saveAll() async {
    setState(() => _saving = true);

    final futures = <Future>[];
    for (final svc in _services) {
      final svcId = svc['id'] as String;
      final serviceId = svc['service_id'] as String;
      final entries = _servicePriceEntries[svcId] ?? [];

      final prices = entries
          .where((e) =>
              e.pricingUnitId != null &&
              e.priceController.text.trim().isNotEmpty)
          .map((e) {
        final pwMat = e.priceWithMaterialController.text.trim();
        return {
          'pricingUnitId': e.pricingUnitId,
          'contractTypeId': e.existingContractTypeId,
          'price': int.tryParse(e.priceController.text.trim()) ?? 0,
          'priceWithMaterial':
              pwMat.isNotEmpty ? int.tryParse(pwMat) : null,
          'plusMaterial': e.existingPlusMaterial,
        };
      }).toList();

      futures.add(_dio
          .put(
            ApiEndpoints.updateProviderService,
            data: {
              'serviceId': serviceId,
              'description': _descControllers[svcId]?.text.trim() ?? '',
              'prices': prices,
            },
          )
          .then((_) => true)
          .catchError((_) => false));
    }

    final results = await Future.wait(futures);
    final updated = results.where((r) => r == true).length;
    final failed = results.where((r) => r == false).length;

    if (!mounted) return;

    setState(() => _saving = false);

    if (failed == 0) {
      ref.invalidate(profileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua layanan berhasil diperbarui')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$updated berhasil, $failed gagal diperbarui'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Layanan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('Belum ada layanan'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: _services.map((svc) {
                          return _buildServiceCard(svc, cs);
                        }).toList(),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _saving ? null : _saveAll,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> svc, ColorScheme cs) {
    final svcId = svc['id'] as String;
    final serviceName = svc['services']?['name'] as String? ?? 'Layanan';
    final validUnits = _validUnitsPerService[svcId] ?? [];
    final entries = _servicePriceEntries[svcId] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.miscellaneous_services_outlined,
                    size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(serviceName,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descControllers[svcId],
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                labelStyle: TextStyle(color: cs.onSurfaceVariant),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: cs.primary, width: 1.5),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            if (validUnits.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('Tidak ada metode harga untuk layanan ini',
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ),
              )
            else ...[
              ...entries.asMap().entries.map((entry) {
                final idx = entry.key;
                final priceEntry = entry.value;
                return _buildPriceEntry(
                    svcId, priceEntry, validUnits, idx, cs);
              }),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _addPriceEntry(svcId),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          size: 16, color: cs.primary),
                      const SizedBox(width: 4),
                      Text('Tambah Satuan',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceEntry(
    String svcId,
    _EditPriceEntry priceEntry,
    List<Map<String, dynamic>> validUnits,
    int index,
    ColorScheme cs,
  ) {
    final selectedUnit = _findUnit(validUnits, priceEntry.pricingUnitId);

    final usedUnitIds = _servicePriceEntries[svcId]!
        .where((e) => e != priceEntry && e.pricingUnitId != null)
        .map((e) => e.pricingUnitId!)
        .toSet();

    final availableUnits =
        validUnits.where((u) => !usedUnitIds.contains(u['id'])).toList();

    if (priceEntry.pricingUnitId != null &&
        !availableUnits.any((u) => u['id'] == priceEntry.pricingUnitId)) {
      availableUnits.insert(0, selectedUnit!);
    }

    final unitLabel = selectedUnit != null
        ? (selectedUnit['name'] as String? ?? '').replaceAll('_', ' ')
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: priceEntry.pricingUnitId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Satuan Harga',
                      labelStyle: TextStyle(color: cs.onSurfaceVariant),
                      filled: true,
                      fillColor:
                          cs.surfaceContainerLow.withValues(alpha: 0.4),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: cs.primary, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      isDense: true,
                    ),
                    items: availableUnits.map((u) {
                      final name =
                          (u['name'] as String? ?? '').replaceAll('_', ' ');
                      final unit = u['unit'] as String? ?? '';
                      return DropdownMenuItem(
                        value: u['id'] as String,
                        child: Text('$name (/ $unit)',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        priceEntry.pricingUnitId = v;
                        final unitData = _findUnit(validUnits, v);
                        priceEntry.hasMaterial =
                            unitData?['has_material'] == true;
                      });
                    },
                  ),
                ),
                if (_servicePriceEntries[svcId]!.length > 1) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _removePriceEntry(svcId, index),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: cs.error.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, size: 16, color: cs.error),
                    ),
                  ),
                ],
              ],
            ),
            if (priceEntry.pricingUnitId != null) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: priceEntry.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Harga $unitLabel',
                  hintText: 'Masukkan harga',
                  hintStyle: TextStyle(
                      color: cs.onSurface.withValues(alpha: 0.4)),
                  suffixText: selectedUnit != null
                      ? '/${selectedUnit['unit']}'
                      : '',
                  suffixStyle: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 13),
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                      color: cs.onSurfaceVariant, fontSize: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: cs.primary, width: 1.5),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
              if (priceEntry.hasMaterial) ...[
                const SizedBox(height: 6),
                TextFormField(
                  controller: priceEntry.priceWithMaterialController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga $unitLabel + Material',
                    hintText: 'Harga jika include material',
                    hintStyle: TextStyle(
                        color: cs.onSurface.withValues(alpha: 0.4)),
                    suffixText: selectedUnit != null
                        ? '/${selectedUnit['unit']}'
                        : '',
                    suffixStyle: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 13),
                    prefixText: 'Rp ',
                    prefixStyle: TextStyle(
                        color: cs.onSurfaceVariant, fontSize: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: cs.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: cs.primary, width: 1.5),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
