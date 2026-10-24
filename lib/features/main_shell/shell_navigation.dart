import 'package:flutter/foundation.dart';

/// Shared tab index for website header ↔ [MainShellScreen].
///
/// Exists because [WebsiteFrame] wraps the navigator and cannot reach
/// [MainShellScreen] via [BuildContext] ancestry.
class ShellNavigation extends ChangeNotifier {
  ShellNavigation._();
  static final ShellNavigation instance = ShellNavigation._();

  int _index = 0;

  int get index => _index;

  void switchTab(int index) {
    if (index < 0 || index > 4 || index == _index) return;
    _index = index;
    notifyListeners();
  }

  void setIndex(int index) {
    if (index < 0 || index > 4) return;
    if (index == _index) return;
    _index = index;
    notifyListeners();
  }
}
