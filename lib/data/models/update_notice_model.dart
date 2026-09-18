class UpdateNotice {
  final String category; // "Maintenance", "Safety", "Social Events", "Utilities"
  final String tag;      // "High Urgency", "Planned", "Info", "General", "Urgent"
  final String date;     // "October 24, 2023", "2 days ago", etc.
  final String title;
  final String description;
  final String? imageAsset;
  final String? secondaryImageAsset;
  final String? statusBadge;

  const UpdateNotice({
    required this.category,
    required this.tag,
    required this.date,
    required this.title,
    required this.description,
    this.imageAsset,
    this.secondaryImageAsset,
    this.statusBadge,
  });
}
