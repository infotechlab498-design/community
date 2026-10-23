import 'package:flutter/foundation.dart';

class PrayerPreferences extends ChangeNotifier {
  PrayerPreferences._();

  static final PrayerPreferences instance = PrayerPreferences._();

  bool _use24Hour = false;

  bool get use24Hour => _use24Hour;

  void setUse24Hour(bool value) {
    if (_use24Hour == value) return;
    _use24Hour = value;
    notifyListeners();
  }
}
