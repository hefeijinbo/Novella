import 'package:flutter/widgets.dart';

/// A single item inside [AdaptiveActionGroup].
class AdaptiveActionGroupItem {
  const AdaptiveActionGroupItem({
    this.iosSymbol,
    this.icon,
    this.title,
    this.onPressed,
    this.enabled = true,
    this.loading = false,
  }) : assert(
         iosSymbol != null || icon != null || title != null || loading,
         'At least one of iosSymbol, icon, title, or loading must be provided',
       );

  final String? iosSymbol;
  final IconData? icon;
  final String? title;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool loading;

  Map<String, dynamic> toNativeMap() {
    return {
      if (iosSymbol != null) 'icon': iosSymbol,
      if (title != null) 'title': title,
      'enabled': enabled && onPressed != null && !loading,
      'loading': loading,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdaptiveActionGroupItem &&
        other.iosSymbol == iosSymbol &&
        other.icon == icon &&
        other.title == title &&
        other.enabled == enabled &&
        other.loading == loading;
  }

  @override
  int get hashCode => Object.hash(iosSymbol, icon, title, enabled, loading);
}
