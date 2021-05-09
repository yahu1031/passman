import 'package:flutter/material.dart';

class FloatingNavbarItem {
  FloatingNavbarItem({
    this.icon,
    this.customWidget = const SizedBox(),
  });

  final IconData? icon;
  final Widget customWidget;
}
