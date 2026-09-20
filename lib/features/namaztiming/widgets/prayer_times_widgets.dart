import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/utils/time_formatter.dart';
import '../../../data/models/prayer_time_model.dart';

class PrayerBrandHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback onOpenSettings;

  const PrayerBrandHeader({
    super.key,
    required this.showBackButton,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showBackButton)
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.prayerNavy,
              ),
            ),
          ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.prayerLavender,
            borderRadius: BorderRadius.circular(AppRadii.small),
          ),
          child: const Icon(
            Icons.home_rounded,
            color: AppColors.primaryPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Neighbor',
                  style: TextStyle(
                    color: AppColors.prayerNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: 'Hub',
                  style: TextStyle(
                    color: AppColors.primaryPurple,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            tooltip: 'Open prayer settings',
            onPressed: onOpenSettings,
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.prayerNavy,
            ),
          ),
        ),
      ],
    );
  }
}

class PrayerGreeting extends StatelessWidget {
  final DateTime now;

  const PrayerGreeting({super.key, required this.now});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assalamu Alaikum 👋',
          style: TextStyle(
            color: AppColors.primaryPurple,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          TimeFormatter.greetingFor(now),
          style: const TextStyle(
            color: AppColors.prayerNavy,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class PrayerLocationButton extends StatelessWidget {
  final PrayerLocation location;
  final VoidCallback onTap;

  const PrayerLocationButton({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change prayer location, currently ${location.label}',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.mediumAll,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  location.label,
                  style: const TextStyle(
                    color: AppColors.prayerMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: AppColors.prayerMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentPrayerCard extends StatelessWidget {
  final PrayerDaySnapshot snapshot;
  final bool use24Hour;
  final VoidCallback onViewAll;

  const CurrentPrayerCard({
    super.key,
    required this.snapshot,
    required this.use24Hour,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final current = snapshot.currentPrayer;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
        decoration: const BoxDecoration(
          borderRadius: AppRadii.heroAll,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryPurple, AppColors.prayerGradientEnd],
          ),
          boxShadow: AppShadows.hero,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CURRENT PRAYER',
              style: TextStyle(
                color: Color(0xE6FFFFFF),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              current.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              TimeFormatter.formatTime(current.startTime, use24Hour: use24Hour),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: PrayerCountdownText(
                    prefix: snapshot.nextIsTomorrow
                        ? 'Next: ${snapshot.nextPrayer.name} tomorrow in '
                        : 'Next: ${snapshot.nextPrayer.name} in ',
                    target: snapshot.nextPrayerTime,
                    style: const TextStyle(
                      color: Color(0xF2FFFFFF),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _HeroActionChip(label: 'View All', onTap: onViewAll),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeroActionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x33FFFFFF),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.home_outlined, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerCountdownText extends StatefulWidget {
  final String prefix;
  final DateTime target;
  final TextStyle style;

  const PrayerCountdownText({
    super.key,
    required this.prefix,
    required this.target,
    required this.style,
  });

  @override
  State<PrayerCountdownText> createState() => _PrayerCountdownTextState();
}

class _PrayerCountdownTextState extends State<PrayerCountdownText> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.target.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.target.difference(DateTime.now()));
    });
  }

  @override
  void didUpdateWidget(covariant PrayerCountdownText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _remaining = widget.target.difference(DateTime.now());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.prefix}${TimeFormatter.formatCountdown(_remaining)}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: widget.style,
    );
  }
}

class PrayerScheduleCard extends StatelessWidget {
  final PrayerDaySnapshot snapshot;
  final bool use24Hour;
  final ValueChanged<PrayerTime> onSelect;

  const PrayerScheduleCard({
    super.key,
    required this.snapshot,
    required this.use24Hour,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadii.largeAll,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          for (var i = 0; i < snapshot.prayers.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                color: AppColors.prayerBorder,
                indent: 20,
                endIndent: 20,
              ),
            PrayerTimeRow(
              prayer: snapshot.prayers[i],
              status: snapshot.rowStatus(snapshot.prayers[i]),
              timeLabel: TimeFormatter.formatTime(
                snapshot.prayers[i].startTime,
                use24Hour: use24Hour,
              ),
              semanticsLabel: snapshot.semanticsFor(snapshot.prayers[i]),
              onTap: () => onSelect(snapshot.prayers[i]),
            ),
          ],
        ],
      ),
    );
  }
}

class PrayerTimeRow extends StatelessWidget {
  final PrayerTime prayer;
  final PrayerRowStatus status;
  final String timeLabel;
  final String semanticsLabel;
  final VoidCallback onTap;

  const PrayerTimeRow({
    super.key,
    required this.prayer,
    required this.status,
    required this.timeLabel,
    required this.semanticsLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = status == PrayerRowStatus.current;
    final isPast = status == PrayerRowStatus.past;
    final navy = isPast
        ? AppColors.prayerNavy.withValues(alpha: 0.45)
        : AppColors.prayerNavy;
    final muted = isPast
        ? AppColors.prayerMuted.withValues(alpha: 0.55)
        : AppColors.prayerArabic;

    return Semantics(
      button: true,
      label: '$semanticsLabel ${prayer.name} at $timeLabel',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isCurrent ? AppColors.prayerLavender : Colors.transparent,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primaryPurple
                        : AppColors.prayerLavender,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    prayer.icon,
                    size: 20,
                    color: isCurrent
                        ? Colors.white
                        : AppColors.primaryPurple.withValues(
                            alpha: isPast ? 0.45 : 1,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          prayer.name,
                          style: TextStyle(
                            color: navy,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          prayer.arabicName,
                          style: TextStyle(
                            color: muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeLabel,
                  style: TextStyle(
                    color: navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Now',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primaryPurple.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextPrayerCard extends StatelessWidget {
  final PrayerDaySnapshot snapshot;
  final bool use24Hour;
  final VoidCallback onTap;

  const NextPrayerCard({
    super.key,
    required this.snapshot,
    required this.use24Hour,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final next = snapshot.nextPrayer;
    final time = TimeFormatter.formatTime(
      snapshot.nextPrayerTime,
      use24Hour: use24Hour,
    );
    final label = snapshot.nextIsTomorrow
        ? '${next.name} tomorrow · $time'
        : '${next.name} · $time';

    return Material(
      color: AppColors.prayerLavender,
      borderRadius: AppRadii.largeAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.largeAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Next Prayer',
                      style: TextStyle(
                        color: AppColors.prayerMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.prayerNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  children: [
                    Text(
                      'View Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PrayerTimesSkeleton extends StatelessWidget {
  const PrayerTimesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block({double height = 18, double width = 140}) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.prayerLavender,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        block(height: 16, width: 180),
        const SizedBox(height: 8),
        block(height: 32, width: 220),
        const SizedBox(height: 22),
        Container(
          height: 148,
          decoration: const BoxDecoration(
            color: AppColors.prayerLavender,
            borderRadius: AppRadii.heroAll,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 280,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadii.largeAll,
          ),
        ),
      ],
    );
  }
}

class MosqueSilhouette extends StatelessWidget {
  const MosqueSilhouette({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(painter: _MosquePainter(), size: const Size(170, 140)),
    );
  }
}

class _MosquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x2A7C3AED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dome = Path()
      ..moveTo(size.width * 0.28, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.52,
        size.height * 0.02,
        size.width * 0.76,
        size.height * 0.42,
      );
    canvas.drawPath(dome, paint);

    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.42),
      Offset(size.width * 0.28, size.height * 0.92),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.76, size.height * 0.42),
      Offset(size.width * 0.76, size.height * 0.92),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.28, size.height * 0.92),
      Offset(size.width * 0.76, size.height * 0.92),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.08),
      Offset(size.width * 0.52, size.height * 0.0),
      paint,
    );
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.0), 2.2, paint);

    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.55),
      Offset(size.width * 0.18, size.height * 0.92),
      paint,
    );
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.5), 7, paint);

    canvas.drawLine(
      Offset(size.width * 0.88, size.height * 0.55),
      Offset(size.width * 0.88, size.height * 0.92),
      paint,
    );
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.5), 7, paint);

    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.42,
        size.height * 0.62,
        size.width * 0.2,
        size.height * 0.3,
      ),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
