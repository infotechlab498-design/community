
import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/water_schedule_model.dart';
import '../../../data/services/water_schedule_api.dart';
import '../admin_common.dart';

class AdminWaterScheduleScreen extends StatefulWidget {
  const AdminWaterScheduleScreen({super.key});

  @override
  State<AdminWaterScheduleScreen> createState() =>
      _AdminWaterScheduleScreenState();
}

class _AdminWaterScheduleScreenState
    extends State<AdminWaterScheduleScreen> {
  final WaterScheduleApi _api = WaterScheduleApi();

  List<WaterScheduleItem> _schedule = [];
  final Map<int, TextEditingController> _timeControllers = {};
  final Map<int, String> _statuses = {};

  bool _loading = true;
  final Set<int> _savingIds = {};
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });

    try {
      final items = await _api.getSchedule();

      if (!mounted) return;

      for (final item in items) {
        _timeControllers[item.id]?.dispose();
        _timeControllers[item.id] =
            TextEditingController(text: item.time);
        _statuses[item.id] = item.status;
      }

      setState(() {
        _schedule = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = _message(error);
      });
    }
  }

  Future<void> _saveSchedule(WaterScheduleItem item) async {
    if (_savingIds.contains(item.id)) return;

    final time = _timeControllers[item.id]?.text.trim() ?? '';
    final status = _statuses[item.id] ?? item.status;

    if (time.isEmpty) {
      setState(() => _error = 'Enter the timing for ${item.day}.');
      return;
    }

    setState(() {
      _savingIds.add(item.id);
      _error = null;
      _success = null;
    });

    try {
      final updated = await _api.updateSchedule(
        id: item.id,
        time: time,
        status: status,
      );

      if (!mounted) return;

      setState(() {
        final index = _schedule.indexWhere(
          (entry) => entry.id == updated.id,
        );

        if (index != -1) {
          _schedule[index] = updated;
        }

        _timeControllers[updated.id]?.text = updated.time;
        _statuses[updated.id] = updated.status;
        _success = '${updated.day} schedule updated successfully.';
      });
    } catch (error) {
      if (!mounted) return;

      if (error is SessionExpiredException) {
        handleAdminError(context, error);
        return;
      }
      setState(() => _error = _message(error));
    } finally {
      if (mounted) {
        setState(() => _savingIds.remove(item.id));
      }
    }
  }

  String _message(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    for (final controller in _timeControllers.values) {
      controller.dispose();
    }
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF6038A8);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FA),
      appBar: AppBar(
        title: const Text('Water Schedule'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF20202A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh schedule',
            onPressed: _loading ? null : _loadSchedule,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: primary),
            )
          : RefreshIndicator(
              onRefresh: _loadSchedule,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: Colors.white,
                          size: 34,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Community Water Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Update distribution hours and daily status.',
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_error != null)
                    _MessageCard(
                      message: _error!,
                      color: Colors.red,
                    ),

                  if (_success != null)
                    _MessageCard(
                      message: _success!,
                      color: Colors.green,
                    ),

                  if (_schedule.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No water schedule found. Add the initial '
                        'weekday records to the database.',
                        textAlign: TextAlign.center,
                      ),
                    ),

                  for (final item in _schedule)
                    _buildDayCard(item),

                  const SizedBox(height: 20),
                  const Text(
                    'Changes are saved to the server when you press Save.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDayCard(WaterScheduleItem item) {
    final saving = _savingIds.contains(item.id);
    final status = _statuses[item.id] ?? item.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF6038A8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.day,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'Open'
                        ? const Color(0xFFE2F6E9)
                        : const Color(0xFFFFE8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Open'
                          ? const Color(0xFF19713B)
                          : const Color(0xFFB3261E),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            TextField(
              controller: _timeControllers[item.id],
              enabled: !saving,
              decoration: const InputDecoration(
                labelText: 'Water timing',
                hintText: '9:00 AM - 11:00 AM',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              initialValue: status,
              decoration: const InputDecoration(
                labelText: 'Distribution status',
                prefixIcon: Icon(Icons.water_drop_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Open',
                  child: Text('Open'),
                ),
                DropdownMenuItem(
                  value: 'Closed',
                  child: Text('Closed'),
                ),
              ],
              onChanged: saving
                  ? null
                  : (value) {
                      if (value == null) return;
                      setState(() => _statuses[item.id] = value);
                    },
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: saving
                    ? null
                    : () => _saveSchedule(item),
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(saving ? 'Saving...' : 'Save ${item.day}'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6038A8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;
  final Color color;

  const _MessageCard({
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: color),
      ),
    );
  }
}
