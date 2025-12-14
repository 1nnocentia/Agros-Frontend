

import 'package:flutter/material.dart';

class ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value ? "Basic Mode" : "Advanced Mode",
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 30,
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}