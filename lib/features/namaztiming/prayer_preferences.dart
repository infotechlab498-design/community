import 'package:flutter/foundation.dart';

import '../../data/models/prayer_time_model.dart';

class PrayerPreferences extends ChangeNotifier {
  PrayerPreferences._();

  static final PrayerPreferences instance = PrayerPreferences._();

  PrayerLocation _location = PrayerLocation.rawalpindi;
  bool _use24Hour = false;

  PrayerLocation get location => _location;
  bool get use24Hour => _use24Hour;

  void setLocation(PrayerLocation location) {
    if (_location.id == location.id) return;
    _location = location;
    notifyListeners();
  }

  void setUse24Hour(bool value) {
    if (_use24Hour == value) return;
    _use24Hour = value;
    notifyListeners();
  }
}
