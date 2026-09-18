import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/update_notice_model.dart';
import '../../data/repositories/community_repository.dart';
import '../../shared/widgets/header_top_app_bar.dart';

class OfficialUpdatesScreen extends StatefulWidget {
  final bool showBackButton;

  const OfficialUpdatesScreen({super.key, this.showBackButton = true});

  @override
  State<OfficialUpdatesScreen> createState() => _OfficialUpdatesScreenState();
}

class _OfficialUpdatesScreenState extends State<OfficialUpdatesScreen> {
  String _activeTab = 'All Announcements';

  final List<String> _tabs = const [
    'All Announcements',
    'Maintenance',
    'Safety',
    'Social Events',
    'Utilities',
  ];

  bool _isHeroBanner(UpdateNotice notice) {
    return notice.imageAsset == AppAssets.upgrade;
  }

  bool _isHighUrgency(UpdateNotice notice) {
    return notice.tag.toLowerCase().contains('urgenc') ||
        notice.tag.toLowerCase().contains('urgent');
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return AppColors.primaryPurple;
      case 'safety':
        return const Color(0xFFE11D48); // Emergency Red
      case 'social events':
        return const Color(0xFF059669); // Emerald Green
      case 'utilities':
        return const Color(0xFF2563EB); // Royal Blue
      default:
        return AppColors.primaryPurple;
    }
  }

  Color _getCategoryBgColor(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return const Color(0xFFF3E8FF);
      case 'safety':
        return const Color(0xFFFFE4E6);
      case 'social events':
        return const Color(0xFFD1FAE5);
      case 'utilities':
        return const Color(0xFFDBEAFE);
      default:
        return const Color(0xFFF3E8FF);
    }
  }

  void _showNoticeDetailModal(BuildContext context, UpdateNotice notice) {
    final categoryColor = _getCategoryColor(notice.category);
    final isUrgent = _isHighUrgency(notice);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Badges Row
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isUrgent
                          ? AppColors.fireDarkRed
                          : _getCategoryBgColor(notice.category),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      notice.tag.toUpperCase(),
                      style: TextStyle(
                        color: isUrgent ? Colors.white : categoryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      notice.category,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    notice.date,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                notice.title.replaceAll('\n', ' '),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),

              // Hero image if available
              if (_isHeroBanner(notice) && notice.imageAsset != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      notice.imageAsset!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Description Body
              Text(
                notice.description,
                style: const TextStyle(
                  color: AppColors.textBody,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              if (notice.statusBadge != null) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Status: ${notice.statusBadge!}',
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        'Dismiss',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Acknowledged "${notice.title.replaceAll('\n', ' ')}"',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.primaryPurple,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Acknowledge',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allNotices = CommunityRepository.getOfficialUpdates();
    final filteredNotices = _activeTab == 'All Announcements'
        ? allNotices
        : allNotices.where((notice) => notice.category == _activeTab).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: HeaderTopAppBar(showBackButton: widget.showBackButton),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title & Subtitle Header
            const Text(
              'Official Updates',
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Stay informed with the latest community announcements, maintenance schedules, and essential safety notices from your Resident Sanctuary team.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),

            // Horizontal Category Selector with Count
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tab = _tabs[index];
                  final isSelected = _activeTab == tab;
                  final count = tab == 'All Announcements'
                      ? allNotices.length
                      : allNotices
                          .where((item) => item.category == tab)
                          .length;

                  return InkWell(
                    onTap: () => setState(() => _activeTab = tab),
                    borderRadius: BorderRadius.circular(9999),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryPurple
                            : Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryPurple
                              : Colors.grey.shade200,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryPurple.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tab,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withAlpha(50)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 20),

            // Filtered Announcement Cards
            if (filteredNotices.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.only(top: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'No updates in $_activeTab',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...filteredNotices.map((notice) {
                if (_isHeroBanner(notice)) {
                  return _buildHeroBannerCard(context, notice);
                } else if (_isHighUrgency(notice)) {
                  return _buildUrgentAlertCard(context, notice);
                } else {
                  return _buildStandardNoticeCard(context, notice);
                }
              }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  /// 1. Hero Renovation / Featured Announcement Card with full-width banner
  Widget _buildHeroBannerCard(BuildContext context, UpdateNotice notice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showNoticeDetailModal(context, notice),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured Image Banner
            if (notice.imageAsset != null)
              Stack(
                children: [
                  Image.asset(
                    notice.imageAsset!,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        notice.tag.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(160),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        notice.date,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title.replaceAll('\n', ' '),
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notice.description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'View Project Details',
                        style: TextStyle(
                          color: AppColors.primaryPurple,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 15,
                        color: AppColors.primaryPurple,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 2. High Urgency / Critical Alert Card with accent highlights
  Widget _buildUrgentAlertCard(BuildContext context, UpdateNotice notice) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDD3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE11D48).withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showNoticeDetailModal(context, notice),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge & Date Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D48),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              notice.tag.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notice.category,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    notice.date,
                    style: const TextStyle(
                      color: Color(0xFFE11D48),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                notice.title.replaceAll('\n', ' '),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                notice.description,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              if (notice.statusBadge != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timelapse_rounded,
                          size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Text(
                        'Status: ${notice.statusBadge!}',
                        style: const TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 3. Standard Community Notice Card with structured icon container & metadata
  Widget _buildStandardNoticeCard(BuildContext context, UpdateNotice notice) {
    final categoryColor = _getCategoryColor(notice.category);
    final categoryBg = _getCategoryBgColor(notice.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F2F5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showNoticeDetailModal(context, notice),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dedicated Category / Asset Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: categoryBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: notice.imageAsset != null
                    ? Image.asset(
                        notice.imageAsset!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          _getCategoryFallbackIcon(notice.category),
                          color: categoryColor,
                          size: 22,
                        ),
                      )
                    : Icon(
                        _getCategoryFallbackIcon(notice.category),
                        color: categoryColor,
                        size: 22,
                      ),
              ),
              const SizedBox(width: 14),

              // Content Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tag & Timestamp
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: categoryBg,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            notice.tag,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          notice.date,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      notice.title.replaceAll('\n', ' '),
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      notice.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),

                    if (notice.statusBadge != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          notice.statusBadge!,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Trailing Action Chevron
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryFallbackIcon(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return Icons.build_outlined;
      case 'safety':
        return Icons.shield_outlined;
      case 'social events':
        return Icons.eco_outlined;
      case 'utilities':
        return Icons.lightbulb_outline;
      default:
        return Icons.notifications_none_outlined;
    }
  }
}

