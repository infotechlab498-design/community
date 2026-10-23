import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/gym_schedule_model.dart';
import '../../../data/repositories/gym_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

class AdminGymScreen extends StatefulWidget {
  const AdminGymScreen({super.key});

  @override
  State<AdminGymScreen> createState() => _AdminGymScreenState();
}

class _AdminGymScreenState extends State<AdminGymScreen> {
  final GymRepository _repository = GymRepository();
  List<GymSession> _sessions = const [];
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
      final sessions = await _repository.fetchSessions();
      if (!mounted) return;
      setState(() {
        _sessions = sessions;
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

  Future<void> _openForm([GymSession? session]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _GymSessionForm(
          repository: _repository,
          session: session,
          nextSortOrder: _sessions.length + 1,
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(GymSession session) async {
    if (!await confirmAdminDelete(context, session.title)) return;
    setState(() => _deleting.add(session.id));
    try {
      await _repository.delete(session.id);
      if (!mounted) return;
      setState(() => _sessions = _sessions.where((s) => s.id != session.id).toList());
      showAdminSuccess(context, '${session.title} deleted.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _deleting.remove(session.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar('Gym Timing', onRefresh: _loading ? null : _load),
      floatingActionButton: _loading || _error != null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: adminPrimary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add session'),
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
            icon: Icons.fitness_center_outlined,
            title: 'Gym Sessions',
            subtitle: 'Add, edit, or remove the daily gym time slots shown to residents.',
          ),
          if (_sessions.isEmpty)
            const EmptyStateView(
              icon: Icons.fitness_center_outlined,
              title: 'No sessions yet',
              message: 'Tap "Add session" to create the first gym slot.',
            ),
          for (final session in _sessions)
            Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                leading: CircleAvatar(
                  backgroundColor: adminPrimary.withAlpha(26),
                  child: Icon(
                    session.audience == GymAudience.female ? Icons.female : Icons.male,
                    color: adminPrimary,
                  ),
                ),
                title: Text(session.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${session.audienceLabel} · ${session.timeRangeLabel}'),
                onTap: () => _openForm(session),
                trailing: _deleting.contains(session.id)
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: 'Delete',
                        icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                        onPressed: () => _delete(session),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GymSessionForm extends StatefulWidget {
  final GymRepository repository;
  final GymSession? session;
  final int nextSortOrder;

  const _GymSessionForm({
    required this.repository,
    required this.session,
    required this.nextSortOrder,
  });

  @override
  State<_GymSessionForm> createState() => _GymSessionFormState();
}

class _GymSessionFormState extends State<_GymSessionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _sortOrder;
  late GymAudience _audience;
  late String _start;
  late String _end;
  bool _saving = false;

  bool get _isEdit => widget.session != null;

  @override
  void initState() {
    super.initState();
    final s = widget.session;
    _title = TextEditingController(text: s?.title ?? '');
    _sortOrder = TextEditingController(text: '${s?.sortOrder ?? widget.nextSortOrder}');
    _audience = s?.audience ?? GymAudience.male;
    _start = s?.startTime ?? '09:00';
    _end = s?.endTime ?? '11:00';
  }

  @override
  void dispose() {
    _title.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final picked = await pickApiTime(context, initial: _start);
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await pickApiTime(context, initial: _end);
    if (picked != null) setState(() => _end = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (apiTimeToMinutes(_end) <= apiTimeToMinutes(_start)) {
      handleAdminError(context, const ApiException('End time must be after start time.'));
      return;
    }
    final session = GymSession(
      id: widget.session?.id ?? 0,
      title: _title.text.trim(),
      audience: _audience,
      startTime: _start,
      endTime: _end,
      sortOrder: int.parse(_sortOrder.text.trim()),
    );
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await widget.repository.update(session);
      } else {
        await widget.repository.create(session);
      }
      if (!mounted) return;
      showAdminSuccess(context, '${session.title} saved.');
      Navigator.of(context).pop(true);
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
      appBar: buildAdminAppBar(_isEdit ? 'Edit Session' : 'New Session'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              enabled: !_saving,
              maxLength: 100,
              decoration: const InputDecoration(
                labelText: 'Session title',
                hintText: 'Male Morning',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a title.' : null,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<GymAudience>(
              initialValue: _audience,
              decoration: const InputDecoration(
                labelText: 'Audience',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: const [
                DropdownMenuItem(value: GymAudience.male, child: Text('Male')),
                DropdownMenuItem(value: GymAudience.female, child: Text('Female')),
              ],
              onChanged: _saving ? null : (v) => setState(() => _audience = v ?? _audience),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TimeField(
                    label: 'Start',
                    value: _start,
                    onTap: _saving ? null : _pickStart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TimeField(
                    label: 'End',
                    value: _end,
                    onTap: _saving ? null : _pickEnd,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _sortOrder,
              enabled: !_saving,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Display order',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) {
                final n = int.tryParse(v?.trim() ?? '');
                return (n == null || n < 0 || n > 1000) ? 'Enter a number from 0 to 1000.' : null;
              },
            ),
            const SizedBox(height: 24),
            AdminSaveButton(saving: _saving, label: 'Save Session', onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _TimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(formatApiTime(value)),
      ),
    );
  }
}
