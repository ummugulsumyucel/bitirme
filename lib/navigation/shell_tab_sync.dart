import 'package:flutter/material.dart';

/// [MainShell] içindeki [IndexedStack] ile aynı sıra.
abstract final class ShellTabs {
  static const int home = 0;
  static const int events = 1;
  static const int calendar = 2;
  static const int profile = 3;
  static const int listings = 4;
  static const int notes = 5;
}

/// Üzerine açılan sayfalardaki alt gezinme, ana kabuktaki sekmeyi seçer.
class ShellTabSync {
  ShellTabSync._();

  static void Function(int index)? _onSelect;

  static void register(void Function(int index) fn) {
    _onSelect = fn;
  }

  static void unregister(void Function(int index) fn) {
    if (_onSelect == fn) _onSelect = null;
  }

  static void select(int index) => _onSelect?.call(index);
}

/// Önce ana sekme [HomePage] seçilir, ardından üst rotalar kapatılır.
void popToShellHome(BuildContext context) {
  ShellTabSync.select(ShellTabs.home);
  Navigator.of(context).popUntil((route) => route.isFirst);
}
