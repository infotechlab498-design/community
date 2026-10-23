import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/water_supply_model.dart';
import '../../../data/repositories/water_supply_repository.dart';
import '../../../shared/widgets/async_state_views.dart';
import '../admin_common.dart';

enum _MonthStatus { notCreated, draft, published }

class AdminWaterSupplyScreen extends StatefulWidget {
  const AdminWaterSupplyScreen({super.key});

  @override
  State<AdminWaterSupplyScreen> createState() => _AdminWaterSupplyScreenState();
}

class _AdminWaterSupplyScreenState extends State<AdminWaterSupplyScreen> {
  static const List<String> _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final WaterSupplyRepository _repository = WaterSupplyRepository();
  late DateTime _month;
  List<WaterBlock> _blocks = const [];
  final Map<int, Set<String>> _days = {};
  _MonthStatus _status = _MonthStatus.notCreated;
  bool _loading = true;
  bool _busy = false;
  bool _dirty = false;
  String? _error;
  int _requestId = 0;

  int get _daysInMonth => DateTime(_month.year, _month.month + 1, 0).day;

  bool get _editable => _status != _MonthStatus.published && !_busy;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _load();
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_blocks.isEmpty) {
        final blocks = await _repository.fetchBlocks();
        if (!mounted || requestId != _requestId) return;
        _blocks = blocks;
      }
      final data = await _repository.fetchAdminMonth(_month.year, _month.month);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _days.clear();
        for (var day = 1; day <= _daysInMonth; day++) {
          final blocks = data?.activeBlocksOn(DateTime(_month.year, _month.month, day));
          _days[day] = {...?blocks};
        }
        if (data != null && data.blocks.isNotEmpty) _blocks = data.blocks;
        _status = data == null
            ? _MonthStatus.notCreated
            : (data.isPublished ? _MonthStatus.published : _MonthStatus.draft);
        _dirty = false;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _requestId) return;
      if (e is SessionExpiredException) {
        handleAdminError(context, e);
        return;
      }
      setState(() {
        _loading = false;
        _error = e is ApiException ? e.message : 'Could not load this month.';
      });
    }
  }

  Future<void> _shiftMonth(int delta) async {
    if (_dirty && !await _confirm('Discard changes?', 'Unsaved changes for this month will be lost.', 'Discard')) {
      return;
    }
    _month = DateTime(_month.year, _month.month + delta);
    _load();
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(action)),
        ],
      ),
    );
    return result ?? false;
  }

  void _toggle(int day, String blockId) {
    setState(() {
      final set = _days[day]!;
      if (!set.remove(blockId)) set.add(blockId);
      _dirty = true;
    });
  }

  WaterSupplyMonth _buildMonth() => WaterSupplyMonth(
        year: _month.year,
        month: _month.month,
        isPublished: false,
        blocks: _blocks,
        activeBlocks: {
          for (final entry in _days.entries)
            DateTime(_month.year, _month.month, entry.key): entry.value,
        },
      );

  Future<bool> _saveDraft({bool quiet = false}) async {
    setState(() => _busy = true);
    try {
      await _repository.saveDraft(_buildMonth());
      if (!mounted) return false;
      setState(() {
        _status = _MonthStatus.draft;
        _dirty = false;
      });
      if (!quiet) showAdminSuccess(context, 'Draft saved. Residents will not see it until you publish.');
      return true;
    } catch (e) {
      if (mounted) handleAdminError(context, e);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _publish() async {
    if (!await _confirm('Publish month?', 'Residents will see this schedule immediately.', 'Publish')) {
      return;
    }
    if ((_dirty || _status == _MonthStatus.notCreated) && !await _saveDraft(quiet: true)) return;
    setState(() => _busy = true);
    try {
      await _repository.publish(_month.year, _month.month);
      if (!mounted) return;
      setState(() => _status = _MonthStatus.published);
      showAdminSuccess(context, '${waterMonthName(_month.month)} ${_month.year} published.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _unpublish() async {
    if (!await _confirm('Unpublish month?', 'Residents will no longer see this schedule until you publish again.', 'Unpublish')) {
      return;
    }
    setState(() => _busy = true);
    try {
      await _repository.unpublish(_month.year, _month.month);
      if (!mounted) return;
      setState(() => _status = _MonthStatus.draft);
      showAdminSuccess(context, 'Month moved back to draft. You can edit it now.');
    } catch (e) {
      if (mounted) handleAdminError(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: adminBackground,
      appBar: buildAdminAppBar('Water Supply', onRefresh: _loading || _busy ? null : _load),
      body: Column(
        children: [
          _buildMonthBar(),
          Expanded(child: _buildBody()),
          if (!_loading && _error == null) _buildActions(),
        ],
      ),
    );
  }

  Widget _buildMonthBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Previous month',
            onPressed: _busy ? null : () => _shiftMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '${waterMonthName(_month.month)} ${_month.year}',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                if (!_loading && _error == null) _StatusChip(status: _status, dirty: _dirty),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Next month',
            onPressed: _busy ? null : () => _shiftMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
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
    if (_blocks.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyStateView(
            title: 'No blocks configured',
            message: 'Restart the API to seed the water supply blocks.',
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: _daysInMonth + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
            child: Text(
              _status == _MonthStatus.published
                  ? 'This month is published. Unpublish it to make changes.'
                  : 'Tap the blocks that receive water on each date, then save or publish.',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          );
        }
        final day = index;
        final date = DateTime(_month.year, _month.month, day);
        final active = _days[day] ?? const <String>{};
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _weekdays[date.weekday - 1],
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                    Text(
                      '$day',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final block in _blocks)
                      FilterChip(
                        label: Text(block.id),
                        tooltip: block.name,
                        selected: active.contains(block.id),
                        selectedColor: const Color(0xFFCFF5E5),
                        checkmarkColor: const Color(0xFF087A55),
                        onSelected: _editable ? (_) => _toggle(day, block.id) : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActions() {
    final published = _status == _MonthStatus.published;
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        child: published
            ? FilledButton.icon(
                onPressed: _busy ? null : _unpublish,
                icon: const Icon(Icons.unpublished_outlined),
                label: const Text('Unpublish to edit'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  minimumSize: const Size.fromHeight(48),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : () => _saveDraft(),
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save draft'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _publish,
                      icon: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.publish_outlined),
                      label: const Text('Publish'),
                      style: FilledButton.styleFrom(
                        backgroundColor: adminPrimary,
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _MonthStatus status;
  final bool dirty;

  const _StatusChip({required this.status, required this.dirty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      _MonthStatus.notCreated => ('Not created', Colors.grey.shade700),
      _MonthStatus.draft => ('Draft', Colors.orange.shade800),
      _MonthStatus.published => ('Published', Colors.green.shade700),
    };
    return Text(
      dirty ? '$label · unsaved changes' : label,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}
