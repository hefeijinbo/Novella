import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'adaptive_blur_view.dart';

/// A lightweight grouped liquid-glass container for custom controls.
///
/// This is useful when you want multiple buttons to contribute to one shared
/// glass capsule, without pulling in a full toolbar or scaffold.
class AdaptiveGlassGroup extends StatelessWidget {
  const AdaptiveGlassGroup({
    super.key,
    required this.children,
    this.direction = Axis.horizontal,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    this.borderRadius,
    this.blurStyle = BlurStyle.systemUltraThinMaterial,
    this.showDividers = true,
    this.dividerColor,
    this.dividerThickness = 0.5,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final Axis direction;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final BlurStyle blurStyle;
  final bool showDividers;
  final Color? dividerColor;
  final double dividerThickness;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(direction == Axis.horizontal ? 24 : 20);

    return AdaptiveBlurView(
      blurStyle: blurStyle,
      borderRadius: effectiveBorderRadius,
      child: Padding(
        padding: padding,
        child: Flex(
          direction: direction,
          mainAxisSize: mainAxisSize,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: _buildChildren(context),
        ),
      ),
    );
  }

  List<Widget> _buildChildren(BuildContext context) {
    if (!showDividers || children.length <= 1) {
      return children;
    }

    final resolvedDividerColor = dividerColor ?? _defaultDividerColor(context);
    final result = <Widget>[];

    for (var index = 0; index < children.length; index++) {
      result.add(children[index]);
      if (index == children.length - 1) {
        continue;
      }

      result.add(
        direction == Axis.horizontal
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  width: dividerThickness,
                  height: 22,
                  color: resolvedDividerColor,
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  width: 22,
                  height: dividerThickness,
                  color: resolvedDividerColor,
                ),
              ),
      );
    }

    return result;
  }

  Color _defaultDividerColor(BuildContext context) {
    final brightness = Theme.brightnessOf(context);
    if (brightness == Brightness.dark) {
      return Colors.white.withValues(alpha: 0.18);
    }
    return CupertinoColors.systemGrey3.withValues(alpha: 0.45);
  }
}
