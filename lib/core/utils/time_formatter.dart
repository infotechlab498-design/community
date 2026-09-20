class TimeFormatter {
  TimeFormatter._();

  static String formatTime(DateTime time, {bool use24Hour = false}) {
    if (use24Hour) {
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  static String formatCountdown(Duration remaining) {
    final safe = remaining.isNegative ? Duration.zero : remaining;
    if (safe.inHours >= 1) {
      final hours = safe.inHours;
      final minutes = safe.inMinutes.remainder(60);
      return '${hours}h ${minutes}m';
    }
    if (safe.inMinutes >= 1) {
      return '${safe.inMinutes}m';
    }
    return '${safe.inSeconds}s';
  }

  static String greetingFor(DateTime now) {
    final hour = now.hour;
    final minute = now.minute;
    final minutes = hour * 60 + minute;
    if (minutes >= 5 * 60 && minutes < 12 * 60) return 'Good Morning';
    if (minutes >= 12 * 60 && minutes < 17 * 60) return 'Good Afternoon';
    return 'Good Evening';
  }
}
