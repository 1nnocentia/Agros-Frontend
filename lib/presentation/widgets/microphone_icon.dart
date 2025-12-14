import 'package:flutter/material.dart';

class MicropohoneIcon extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;

  const MicropohoneIcon({
    super.key,
    required this.isListening,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final currentColor = isListening ? colorScheme.error : colorScheme.primary;
    final shadowColor = currentColor.withValues(alpha: 0.4);

    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isListening ? 220 : 200,
            height: isListening ? 220 : 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: currentColor,
              boxShadow: [
                BoxShadow(
                color: shadowColor,
                blurRadius: isListening ? 20 : 20,
                spreadRadius: isListening ? 8 : 2,
                )
              ]
            ),
            child: Icon(
              isListening ? Icons.stop : Icons.mic_none_outlined,
              size: 80,
              color: colorScheme.onPrimary,
            ),
          )
        ),
        const SizedBox(height: 20),

        Text(
          isListening ? "Mendengarkan.." : "Tekan untuk bicara",
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}