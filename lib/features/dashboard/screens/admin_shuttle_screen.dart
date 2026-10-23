import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/shuttle_route_model.dart';
import '../../../data/repositories/shuttle_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

class AdminShuttleScreen extends StatefulWidget {
  const AdminShuttleScreen({super.key});

  @override
  State<AdminShuttleScreen> createState() => _AdminShuttleScreenState();
}

class _AdminShuttleScreenState extends State<AdminShuttleScreen> {
  final ShuttleRepository _repository = ShuttleRepository();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  List<ShuttleRoute> _routes = const [];
  String? _routeId;
  List<String> _times = [];
  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final routes = await _repository.fetchRoutes();
      if (!mounted) return;
      setState(() {
        _routes = routes;
        _loading = false;
        final keep = routes.any((r) => r.id == _routeId);
        _selectRoute(keep ? _routeId : (routes.isEmpty ? null : routes.first.id));
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    }
  }

  void _selectRoute(String? routeId) {
    _routeId = routeId;
    ShuttleRoute? route;
    for (final candidate in _routes) {
      if (candidate.id == routeId) route = candidate;
    }
    _originController.text = route?.origin ?? '';
    _destinationController.text = route?.destination ?? '';
    _times = route?.departures.map((d) => d.time24).toList() ?? [];
    _dirty = false;
  }

  Future<void> _changeRoute(String routeId) async {
    if (routeId == _routeId) return;
    if (_dirty && !await _confirmDiscard()) return;
    setState(() => _selectRoute(routeId));
  }

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Unsaved departure changes on this route will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Discard')),
        ],
      ),
    );
    return result ?? false;
  }

  void _sortTimes() {
    _times.sort((a, b) => apiTimeToMinutes(a).compareTo(apiTimeToMinutes(b)));
  }

  Future<void> _addTime() async {
    final picked = await pickApiTime(context, initial: _times.isEmpty ? null : _times.last);
    if (picked == null || !mounted) return;
    if (_times.contains(picked)) {
      handleAdminError(context, const ApiException('That departure time is already listed.'));
      return;
    }
    setState(() {
      _times.add(picked);
      _sortTimes();
      _dirty = true;
    });
  }

  Future<void> _editTime(int index) async {
    final picked = await pickApiTime(context, initial: _times[index]);
    if (picked == null || !mounted || picked == _times[index]) return;
    if (_times.contains(picked)) {
      handleAdminError(context, const ApiException('That departure time is already listed.'));
      return;
    }
    setState(() {
      _times[index] = picked;
      _sortTimes();
      _dirty = true;
    });
  }

  Future<void> _removeTime(int index) async {
    final label = formatApiTime(_times[index]);
    if (!await confirmAdminDelete(context, label)) return;
    setState(() {
      _times.removeAt(index);
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final routeId = _routeId;
    if (routeId == null) return;
    final origin = _originController.text.trim();
    final destination = _destinationController.text.trim();
    if (origin.isEmpty || destination.isEmpty) {
      handleAdminError(context, const ApiException('Enter both the origin and destination.'));
      return;
    }
    if (_times.isEmpty) {
      handleAdminError(context, const ApiException('Add at least one departure time.'));
      return;
    }
    setState(() => _saving = true);
    try {
      final saved = await _repository.saveRoute(
        routeId: routeId,
        origin: origin,
        destination: destination,
        times: _times,
      );
      if (!mounted) return;
      setState(() {
        _routes = [for (final r in _routes) r.id == saved.id ? saved : r];
        _selectRoute(saved.id);
      });
      showAdminSuccess(context, '${saved.directionLabel} saved.');
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
      appBar: buildAdminAppBar('Shuttle', onRefresh: _loading ? null : _load),
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
    if (_routes.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyStateView(
            title: 'No shuttle routes',
            message: 'Restart the API to seed the default routes.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const AdminHeaderCard(
          icon: Icons.directions_bus_outlined,
          title: 'Shuttle Timings',
          subtitle: 'Pick a route, adjust its departures, then save. Saving replaces that route\'s timetable.',
        ),
        SegmentedButton<String>(
          segments: [
            for (final route in _routes)
              ButtonSegment(value: route.id, label: Text(route.toggleLabel)),
          ],
          selected: {_routeId!},
          onSelectionChanged: _saving ? null : (value) => _changeRoute(value.first),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _originController,
                enabled: !_saving,
                onChanged: (_) => setState(() => _dirty = true),
                decoration: const InputDecoration(
                  labelText: 'From',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _destinationController,
                enabled: !_saving,
                onChanged: (_) => setState(() => _dirty = true),
                decoration: const InputDecoration(
                  labelText: 'To',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${_times.length} departures',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: _saving ? null : _addTime,
              icon: const Icon(Icons.add),
              label: const Text('Add time'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_times.isEmpty)
          const EmptyStateView(
            icon: Icons.schedule_outlined,
            title: 'No departures',
            message: 'Tap "Add time" to add the first departure.',
          ),
        for (var i = 0; i < _times.length; i++)
          Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.schedule, color: adminPrimary),
              title: Text(
                formatApiTime(_times[i]),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: _saving ? null : () => _editTime(i),
              trailing: IconButton(
                tooltip: 'Remove',
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: _saving ? null : () => _removeTime(i),
              ),
            ),
          ),
        const SizedBox(height: 16),
        AdminSaveButton(
          saving: _saving,
          label: 'Save Route',
          onPressed: _dirty ? _save : null,
        ),
      ],
    );
  }
}
