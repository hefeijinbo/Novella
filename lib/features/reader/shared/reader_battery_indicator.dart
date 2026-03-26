import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:novella/features/settings/settings_provider.dart';

class ReaderBatteryIndicator extends StatelessWidget {
  const ReaderBatteryIndicator({
    super.key,
    required this.batteryLevelListenable,
    required this.batteryStateListenable,
    required this.style,
    required this.color,
    this.textStyle,
  });

  final ValueListenable<int> batteryLevelListenable;
  final ValueListenable<BatteryState> batteryStateListenable;
  final ReaderBatteryIndicatorStyle style;
  final Color color;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final themePrimaryContainer = Theme.of(context).colorScheme.primaryContainer;
    final themePrimary = Theme.of(context).colorScheme.primary;
    switch (style) {
      case ReaderBatteryIndicatorStyle.capsule:
        return AnimatedBuilder(
          animation: Listenable.merge([
            batteryLevelListenable,
            batteryStateListenable,
          ]),
          builder: (context, _) {
            final batteryLevel = batteryLevelListenable.value.clamp(0, 100);
            final batteryState = batteryStateListenable.value;
            return _buildCapsule(
              widthFactor: (batteryLevel / 100.0).clamp(0.0, 1.0),
              fillColor: _batteryColor(batteryLevel, batteryState),
              trackColor: color.withValues(alpha: 0.2),
            );
          },
        );
      case ReaderBatteryIndicatorStyle.capsuleDynamic:
        return AnimatedBuilder(
          animation: Listenable.merge([
            batteryLevelListenable,
            batteryStateListenable,
          ]),
          builder: (context, _) {
            final batteryLevel = batteryLevelListenable.value.clamp(0, 100);
            final isCharging =
                batteryStateListenable.value == BatteryState.charging;
            final fillColor = isCharging ? themePrimary : themePrimaryContainer;
            return _buildCapsule(
              widthFactor: (batteryLevel / 100.0).clamp(0.0, 1.0),
              fillColor: fillColor,
              trackColor: fillColor.withValues(alpha: 0.2),
            );
          },
        );
      case ReaderBatteryIndicatorStyle.text:
        return AnimatedBuilder(
          animation: Listenable.merge([
            batteryLevelListenable,
            batteryStateListenable,
          ]),
          builder: (context, _) {
            final batteryLevel = batteryLevelListenable.value.clamp(0, 100);
            final isCharging =
                batteryStateListenable.value == BatteryState.charging;
            return Text(
              isCharging ? '充电中 $batteryLevel%' : '电量 $batteryLevel%',
              style: textStyle,
            );
          },
        );
    }
  }

  Widget _buildCapsule({
    required double widthFactor,
    required Color fillColor,
    required Color trackColor,
  }) {
    return Container(
      width: 36,
      height: 6,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(3),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Color _batteryColor(int batteryLevel, BatteryState batteryState) {
    if (batteryState == BatteryState.charging) {
      return Colors.blue;
    }
    if (batteryLevel <= 15) {
      return Colors.red;
    }
    if (batteryLevel <= 35) {
      return Colors.yellow;
    }
    return const Color(0xFF34C759);
  }
}
