import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/prayer_time_model.dart';
import '../../../data/repositories/prayer_times_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

class AdminPrayerTimesScreen extends StatefulWidget {
  const AdminPrayerTimesScreen({super.key});

  @override
  State<AdminPrayerTimesScreen> createState() => _AdminPrayerTimesScreenState();
}

class _AdminPrayerTimesScreenState extends State<AdminPrayerTimesScreen> {
  final PrayerTimesRepository _repository = PrayerTimesRepository();
  List<PrayerTimeSetting> _settings = const [];
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

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
      final settings = await _repository.fetchSettings();
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _loading = false;
        _dirty = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  Future<void> _pick(int index) async {
    final picked = await pickApiTime(context, initial: _settings[index].time);
    if (picked == null || !mounted) return;
    setState(() {
      _settings = [..._settings]..[index] = _settings[index].copyWith(time: picked);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final saved = await _repository.saveSettings(_settings);
      if (!mounted) return;
      setState(() {
        _settings = saved;
        _dirty = false;
      });
      showAdminSuccess(context, 'Namaz timings saved.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar('Namaz Timing', onRefresh: _loading ? null : _load),
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AdminHeaderCard(
          icon: Icons.mosque_outlined,
          title: 'Namaz Timings',
          subtitle: 'One fixed timetable used every day. Jummah replaces Dhuhr on Fridays.',
        ),
        if (_settings.isEmpty)
          const EmptyStateView(
            title: 'No prayers found',
            message: 'Restart the API to seed the default prayer list.',
          ),
        for (var i = 0; i < _settings.length; i++)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: const Icon(Icons.access_time, color: adminPrimary),
              title: Text(
                _settings[i].name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(formatApiTime(_settings[i].time)),
              trailing: OutlinedButton(
                onPressed: _saving ? null : () => _pick(i),
                child: const Text('Change'),
              ),
              onTap: _saving ? null : () => _pick(i),
            ),
          ),
        const SizedBox(height: 12),
        AdminSaveButton(
          saving: _saving,
          label: 'Save Namaz Timings',
          onPressed: _dirty ? _save : null,
        ),
      ],
    );
  }
}
