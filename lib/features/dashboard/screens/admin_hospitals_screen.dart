import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/hospital_model.dart';
import '../../../data/repositories/hospitals_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

class AdminHospitalsScreen extends StatefulWidget {
  const AdminHospitalsScreen({super.key});

  @override
  State<AdminHospitalsScreen> createState() => _AdminHospitalsScreenState();
}

class _AdminHospitalsScreenState extends State<AdminHospitalsScreen> {
  final HospitalsRepository _repository = HospitalsRepository();
  List<Hospital> _hospitals = const [];
  bool _loading = true;
  String? _error;
  final Set<int> _deleting = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final hospitals = await _repository.fetchHospitals();
      if (!mounted) return;
      setState(() {
        _hospitals = hospitals;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _openForm([Hospital? hospital]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _HospitalForm(
          repository: _repository,
          hospital: hospital,
          nextSortOrder: _hospitals.length + 1,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Hospital hospital) async {
    if (!await confirmAdminDelete(context, hospital.name)) return;
    setState(() => _deleting.add(hospital.id));
    try {
      await _repository.delete(hospital.id);
      if (!mounted) return;
      setState(() => _hospitals = _hospitals.where((h) => h.id != hospital.id).toList());
      showAdminSuccess(context, '${hospital.name} deleted.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _deleting.remove(hospital.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar('Hospitals', onRefresh: _loading ? null : _load),
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: adminPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add hospital'),
            ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingStateView();
    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [ErrorStateView(message: _error!, onRetry: _load)],
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          const AdminHeaderCard(
            icon: Icons.local_hospital_outlined,
            title: 'Hospital Locations',
            subtitle: 'Residents tap a hospital to open these coordinates in Google Maps.',
          ),
          if (_hospitals.isEmpty)
            const EmptyStateView(
              icon: Icons.local_hospital_outlined,
              title: 'No hospitals yet',
              message: 'Tap "Add hospital" to add the first location.',
            ),
          for (final hospital in _hospitals)
            Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: const Icon(Icons.local_hospital_rounded, color: adminPrimary),
                title: Text(hospital.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${hospital.address}\n'
                  '${hospital.latitude.toStringAsFixed(5)}, ${hospital.longitude.toStringAsFixed(5)}',
                ),
                isThreeLine: true,
                onTap: () => _openForm(hospital),
                trailing: _deleting.contains(hospital.id)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: 'Delete',
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                        onPressed: () => _delete(hospital),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HospitalForm extends StatefulWidget {
  final HospitalsRepository repository;
  final Hospital? hospital;
  final int nextSortOrder;

  const _HospitalForm({
    required this.repository,
    required this.hospital,
    required this.nextSortOrder,
  });

  @override
  State<_HospitalForm> createState() => _HospitalFormState();
}

class _HospitalFormState extends State<_HospitalForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _latitude;
  late final TextEditingController _longitude;
  late final TextEditingController _sortOrder;
  bool _saving = false;

  bool get _isEdit => widget.hospital != null;

  @override
  void initState() {
    super.initState();
    final h = widget.hospital;
    _name = TextEditingController(text: h?.name ?? '');
    _address = TextEditingController(text: h?.address ?? '');
    _latitude = TextEditingController(text: h == null ? '' : '${h.latitude}');
    _longitude = TextEditingController(text: h == null ? '' : '${h.longitude}');
    _sortOrder = TextEditingController(text: '${h?.sortOrder ?? widget.nextSortOrder}');
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _latitude.dispose();
    _longitude.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  String? _validateCoordinate(String? value, double limit) {
    final n = double.tryParse(value?.trim() ?? '');
    if (n == null) return 'Enter a number.';
    if (n < -limit || n > limit) return 'Must be between -$limit and $limit.';
    return null;
  }

  Hospital? _buildHospital() {
    if (!_formKey.currentState!.validate()) return null;
    return Hospital(
      id: widget.hospital?.id ?? 0,
      name: _name.text.trim(),
      address: _address.text.trim(),
      latitude: double.parse(_latitude.text.trim()),
      longitude: double.parse(_longitude.text.trim()),
      sortOrder: int.parse(_sortOrder.text.trim()),
    );
  }

  Future<void> _preview() async {
    final hospital = _buildHospital();
    if (hospital == null) return;
    await launchUrl(hospital.mapsUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _save() async {
    final hospital = _buildHospital();
    if (hospital == null) return;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.repository.update(hospital);
      } else {
        await widget.repository.create(hospital);
      }
      if (!mounted) return;
      showAdminSuccess(context, '${hospital.name} saved.');
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      );

  @override
  Widget build(BuildContext context) {
    const coordinateKeyboard = TextInputType.numberWithOptions(decimal: true, signed: true);
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar(_isEdit ? 'Edit Hospital' : 'New Hospital'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              enabled: !_saving,
              maxLength: 150,
              decoration: _decoration('Hospital name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name.' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _address,
              enabled: !_saving,
              maxLength: 250,
              decoration: _decoration('Address'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter an address.' : null,
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitude,
                    enabled: !_saving,
                    keyboardType: coordinateKeyboard,
                    decoration: _decoration('Latitude', hint: '33.6844'),
                    validator: (v) => _validateCoordinate(v, 90),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _longitude,
                    enabled: !_saving,
                    keyboardType: coordinateKeyboard,
                    decoration: _decoration('Longitude', hint: '73.0479'),
                    validator: (v) => _validateCoordinate(v, 180),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sortOrder,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: _decoration('Display order'),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n < 0 || n > 1000) ? 'Enter a number from 0 to 1000.' : null;
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _saving ? null : _preview,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Preview in Google Maps'),
            ),
            const SizedBox(height: 16),
            AdminSaveButton(saving: _saving, label: 'Save Hospital', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
