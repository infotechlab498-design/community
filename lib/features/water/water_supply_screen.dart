import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/water_supply_model.dart';
import '../../data/repositories/water_supply_repository.dart';

enum _ScheduleViewState { loading, loaded, empty, error }

class WaterSupplyScreen extends StatefulWidget {
  final bool showBackButton;

  const WaterSupplyScreen({super.key, this.showBackButton = false});

  @override
  State<WaterSupplyScreen> createState() => _WaterSupplyScreenState();
}

class _WaterSupplyScreenState extends State<WaterSupplyScreen> {
  String _selectedBlockId = 'A';
  late DateTime _selectedMonth;
  DateTime? _selectedDate;
  _ScheduleViewState _viewState = _ScheduleViewState.loading;
  WaterMonthSchedule? _schedule;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void initState() {
    super.initState();
    final today = _today;
    _selectedMonth = DateTime(today.year, today.month);
    _applySchedule();
  }

  void _applySchedule() {
    DateTime? selected = _selectedDate;
    if (selected != null &&
        (selected.year != _selectedMonth.year ||
            selected.month != _selectedMonth.month)) {
      selected = null;
    }
    try {
      final schedule = WaterSupplyRepository.scheduleFor(
        blockId: _selectedBlockId,
        month: _selectedMonth,
        selectedDate: selected,
      );
      _selectedDate = selected;
      _schedule = schedule;
      _viewState = _ScheduleViewState.loaded;
    } catch (_) {
      _schedule = null;
      _viewState = _ScheduleViewState.error;
    }
  }

  void _reload() {
    setState(_applySchedule);
  }

  void _selectBlock(String blockId) {
    if (blockId == _selectedBlockId) return;
    setState(() {
      _selectedBlockId = blockId;
      _applySchedule();
    });
  }

  void _shiftMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
      _selectedDate = null;
      _applySchedule();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _applySchedule();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width < 360
        ? 12.0
        : width < 430
        ? 16.0
        : 20.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FB),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                    _WaterServiceHeader(showBackButton: widget.showBackButton),
                    Transform.translate(
                      offset: const Offset(0, -22),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 560),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              horizontal,
                              0,
                              horizontal,
                              28,
                            ),
                            child: Column(
                              children: [
                                _BlockSelectorCard(
                                  selectedBlockId: _selectedBlockId,
                                  onSelect: _selectBlock,
                                ),
                                const SizedBox(height: 12),
                                _ScheduleCard(
                                  viewState: _viewState,
                                  schedule: _schedule,
                                  selectedDate: _selectedDate,
                                  today: _today,
                                  onRetry: _reload,
                                  onPreviousMonth: () => _shiftMonth(-1),
                                  onNextMonth: () => _shiftMonth(1),
                                  onSelectDate: _selectDate,
                                ),
                                const SizedBox(height: 12),
                                const _QuickNoteCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WaterServiceHeader extends StatelessWidget {
  final bool showBackButton;

  const _WaterServiceHeader({required this.showBackButton});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final illustrationWidth = width < 360
        ? 72.0
        : width < 430
        ? 96.0
        : 118.0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0759A5), Color(0xFF0878C9), Color(0xFF2B9BDE)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 56,
            child: CustomPaint(painter: _HeaderWavePainter()),
          ),
          Positioned(
            right: width < 360 ? 4 : 12,
            bottom: 18,
            child: SizedBox(
              width: illustrationWidth,
              height: illustrationWidth * 0.92,
              child: CustomPaint(painter: _WaterTowerPainter()),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, showBackButton ? 4 : 16, 20, 44),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showBackButton)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'Back',
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.water_drop_rounded,
                          color: AppColors.waterBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Water Service',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'DHA Homes',
                              style: TextStyle(
                                color: Color(0xD9FFFFFF),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: illustrationWidth * 0.35),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width < 400 ? width * 0.62 : 230,
                    ),
                    child: const Text(
                      'Check when water supply is available in your block.',
                      maxLines: 2,
                      style: TextStyle(
                        color: Color(0xF0FFFFFF),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlockSelectorCard extends StatelessWidget {
  final String selectedBlockId;
  final ValueChanged<String> onSelect;

  const _BlockSelectorCard({
    required this.selectedBlockId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14087A9C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stacked = constraints.maxWidth < 340;
          final selector = Row(
            mainAxisSize: MainAxisSize.min,
            children: WaterSupplyRepository.blocks
                .map(
                  (block) => _BlockChip(
                    label: block.id,
                    selected: block.id == selectedBlockId,
                    onTap: () => onSelect(block.id),
                  ),
                )
                .toList(),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _BlockSelectorCopy(),
                const SizedBox(height: 10),
                selector,
              ],
            );
          }

          return Row(
            children: [
              const Expanded(child: _BlockSelectorCopy()),
              selector,
            ],
          );
        },
      ),
    );
  }
}

class _BlockSelectorCopy extends StatelessWidget {
  const _BlockSelectorCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Block',
          style: TextStyle(
            color: AppColors.waterInk,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'View schedule for your block',
          style: TextStyle(color: AppColors.waterMuted, fontSize: 12),
        ),
      ],
    );
  }
}

class _BlockChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BlockChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'Block $label',
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Ink(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.waterGreen
                    : AppColors.waterChipIdle,
                borderRadius: BorderRadius.circular(12),
                border: selected
                    ? null
                    : Border.all(color: AppColors.waterChipBorder),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF334155),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final _ScheduleViewState viewState;
  final WaterMonthSchedule? schedule;
  final DateTime? selectedDate;
  final DateTime today;
  final VoidCallback onRetry;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  const _ScheduleCard({
    required this.viewState,
    required this.schedule,
    required this.selectedDate,
    required this.today,
    required this.onRetry,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14087A9C),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: switch (viewState) {
          _ScheduleViewState.loading => const Padding(
            key: ValueKey('loading'),
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.waterBlue),
            ),
          ),
          _ScheduleViewState.error => _MessageState(
            key: const ValueKey('error'),
            title: 'Unable to update schedule',
            message: 'Check your internet connection and try again.',
            actionLabel: 'Try Again',
            onAction: onRetry,
          ),
          _ScheduleViewState.empty => _MessageState(
            key: const ValueKey('empty'),
            title: 'No schedule available',
            message: 'There is currently no published water supply schedule for this month.',
          ),
          _ScheduleViewState.loaded when schedule != null => _LoadedSchedule(
            key: ValueKey('${schedule!.block.id}-${schedule!.monthLabel}'),
            schedule: schedule!,
            selectedDate: selectedDate,
            today: today,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onSelectDate: onSelectDate,
          ),
          _ => _MessageState(
            key: const ValueKey('unavailable'),
            title: 'Water schedule unavailable',
            message: 'We couldn\'t load the schedule for this block. Please try again.',
            actionLabel: 'Try Again',
            onAction: onRetry,
          ),
        },
      ),
    );
  }
}

class _LoadedSchedule extends StatelessWidget {
  final WaterMonthSchedule schedule;
  final DateTime? selectedDate;
  final DateTime today;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onSelectDate;

  const _LoadedSchedule({
    super.key,
    required this.schedule,
    required this.selectedDate,
    required this.today,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScheduleHeader(schedule: schedule),
        const SizedBox(height: 16),
        _MonthNavigation(
          label: schedule.monthLabel,
          onPrevious: onPreviousMonth,
          onNext: onNextMonth,
        ),
        const SizedBox(height: 12),
        _WaterCalendar(
          schedule: schedule,
          selectedDate: selectedDate,
          today: today,
          onSelectDate: onSelectDate,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: selectedDate == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _DateDetailPanel(
                    schedule: schedule,
                    date: selectedDate!,
                  ),
                ),
        ),
        const SizedBox(height: 14),
        const _CalendarLegend(),
        const SizedBox(height: 14),
        _MonthlySupplySummary(schedule: schedule),
      ],
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  final WaterMonthSchedule schedule;

  const _ScheduleHeader({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final closed = schedule.badgeStatus == WaterSupplyStatus.closed;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.waterGreen,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            schedule.block.id,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.block.name,
                style: const TextStyle(
                  color: AppColors.waterInk,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Water Supply Schedule',
                style: TextStyle(color: AppColors.waterMuted, fontSize: 12),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 132),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: closed
                  ? AppColors.waterClosedFill
                  : AppColors.waterGreenLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.water_drop_rounded,
                  size: 16,
                  color: closed
                      ? AppColors.waterClosedText
                      : AppColors.waterGreen,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.badgeTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: closed
                              ? AppColors.waterClosedText
                              : AppColors.waterGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        schedule.badgeSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: closed
                              ? AppColors.waterMuted
                              : AppColors.waterGreen.withValues(alpha: 0.85),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthNavigation extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthNavigation({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_month_outlined,
          size: 18,
          color: AppColors.waterBlue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.waterInk,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _NavButton(
          tooltip: 'Previous month',
          icon: Icons.chevron_left_rounded,
          onTap: onPrevious,
        ),
        _NavButton(
          tooltip: 'Next month',
          icon: Icons.chevron_right_rounded,
          onTap: onNext,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _NavButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, color: AppColors.waterMuted, size: 26),
      ),
    );
  }
}

class _WaterCalendar extends StatelessWidget {
  final WaterMonthSchedule schedule;
  final DateTime? selectedDate;
  final DateTime today;
  final ValueChanged<DateTime> onSelectDate;

  const _WaterCalendar({
    required this.schedule,
    required this.selectedDate,
    required this.today,
    required this.onSelectDate,
  });

  static const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  List<WaterDayInfo?> _cells() {
    final month = schedule.month;
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = first.weekday % 7;
    final cells = <WaterDayInfo?>[];
    for (var i = 0; i < leading; i++) {
      cells.add(null);
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(month.year, month.month, day);
      final selected =
          selectedDate != null &&
          selectedDate!.year == date.year &&
          selectedDate!.month == date.month &&
          selectedDate!.day == date.day;
      cells.add(
        WaterDayInfo(
          date: date,
          activationStatus: schedule.activationStatusFor(date),
          isToday: date == today,
          isSelected: selected,
        ),
      );
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final cells = _cells();
    return Column(
      children: [
        Row(
          children: _weekdays
              .map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Color(0xFF728197),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cells.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisExtent: 48,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemBuilder: (context, index) {
            final day = cells[index];
            if (day == null) return const SizedBox.shrink();
            return _WaterCalendarDay(
              day: day,
              onTap: () => onSelectDate(day.date),
            );
          },
        ),
      ],
    );
  }
}

class _WaterCalendarDay extends StatelessWidget {
  final WaterDayInfo day;
  final VoidCallback onTap;

  const _WaterCalendarDay({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOpen = day.activationStatus == WaterDayActivationStatus.open;
    final Color fill;
    final Color text;
    switch (day.activationStatus) {
      case WaterDayActivationStatus.open:
        fill = day.isSelected
            ? const Color(0xFFA8EBD0)
            : AppColors.waterOpenFill;
        text = AppColors.waterOpenText;
      case WaterDayActivationStatus.closed:
        fill = day.isSelected
            ? const Color(0xFFDCE6EF)
            : AppColors.waterClosedFill;
        text = AppColors.waterClosedText;
    }

    Border? border;
    if (day.isSelected) {
      border = Border.all(
        color: isOpen ? AppColors.waterGreen : AppColors.waterMuted,
        width: 2,
      );
    } else if (day.isToday) {
      border = Border.all(color: AppColors.waterBlue, width: 1.6);
    }

    return Semantics(
      button: true,
      selected: day.isSelected,
      label: day.accessibilityLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(10),
              border: border,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${day.date.day}',
                  style: TextStyle(
                    color: text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (day.isToday)
                  Positioned(
                    bottom: 6,
                    child: Container(
                      width: 12,
                      height: 2,
                      decoration: BoxDecoration(
                        color: isOpen
                            ? AppColors.waterBlue
                            : AppColors.waterMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateDetailPanel extends StatelessWidget {
  final WaterMonthSchedule schedule;
  final DateTime date;

  const _DateDetailPanel({required this.schedule, required this.date});

  @override
  Widget build(BuildContext context) {
    final open =
        schedule.activationStatusFor(date) == WaterDayActivationStatus.open;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: open ? AppColors.waterGreenLight : AppColors.waterClosedFill,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              open ? 'Water Supply Available' : 'Water Supply Closed',
              style: TextStyle(
                color: open ? AppColors.waterOpenText : AppColors.waterInk,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${schedule.block.name}  ·  ${WaterMonthSchedule.formatFullDate(date)}',
              style: const TextStyle(color: AppColors.waterMuted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(
              open
                  ? 'Supply is scheduled for this date.'
                  : 'No water supply is scheduled for this date.',
              style: const TextStyle(
                color: AppColors.waterMuted,
                fontSize: 12,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _LegendDot(color: AppColors.waterGreen, label: 'Water Supply Open'),
        SizedBox(width: 18),
        _LegendDot(color: Color(0xFFB7C4D1), label: 'Water Supply Closed'),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.waterMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MonthlySupplySummary extends StatelessWidget {
  final WaterMonthSchedule schedule;

  const _MonthlySupplySummary({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final count = schedule.openDayCount;
    final dayWord = count == 1 ? 'day' : 'days';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE4F8F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.waterGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.block.name} has water supply on $count $dayWord this month',
                  style: const TextStyle(
                    color: AppColors.waterOpenText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Check the calendar above for exact dates.',
                  style: TextStyle(color: AppColors.waterMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickNoteCard extends StatelessWidget {
  const _QuickNoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF6FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.waterBlue,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Note',
                  style: TextStyle(
                    color: AppColors.waterDeepBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'The water supply schedule may be subject to changes. Please stay updated with the latest notices.',
                  style: TextStyle(
                    color: AppColors.waterMuted,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 8),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.waterInk,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.waterMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.waterBlue,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0x3326B0E8);
    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..quadraticBezierTo(
        size.width * 0.25,
        0,
        size.width * 0.5,
        size.height * 0.4,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = const Color(0x220C5EA8);
    final path2 = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.2,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WaterTowerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final teal = Paint()
      ..color = const Color(0xCCE8F8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, size.width * 0.035)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = const Color(0x33FFFFFF);

    final tankRect = Rect.fromLTWH(
      size.width * 0.28,
      size.height * 0.08,
      size.width * 0.44,
      size.height * 0.28,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, Radius.circular(size.width * 0.08)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(tankRect, Radius.circular(size.width * 0.08)),
      teal,
    );

    final cap = Path()
      ..moveTo(tankRect.left - 4, tankRect.top + 6)
      ..lineTo(tankRect.center.dx, tankRect.top - size.height * 0.06)
      ..lineTo(tankRect.right + 4, tankRect.top + 6);
    canvas.drawPath(cap, teal);

    canvas.drawLine(
      Offset(tankRect.left + 8, tankRect.bottom),
      Offset(size.width * 0.22, size.height * 0.92),
      teal,
    );
    canvas.drawLine(
      Offset(tankRect.right - 8, tankRect.bottom),
      Offset(size.width * 0.78, size.height * 0.92),
      teal,
    );
    canvas.drawLine(
      Offset(tankRect.center.dx, tankRect.bottom),
      Offset(tankRect.center.dx, size.height * 0.9),
      teal,
    );
    canvas.drawLine(
      Offset(size.width * 0.32, size.height * 0.58),
      Offset(size.width * 0.68, size.height * 0.58),
      teal,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.74),
      Offset(size.width * 0.72, size.height * 0.74),
      teal,
    );

    canvas.drawCircle(Offset(size.width * 0.82, size.height * 0.22), 3, teal);
    canvas.drawCircle(Offset(size.width * 0.14, size.height * 0.18), 2.2, teal);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
