import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';

class BasicView extends StatefulWidget {
  const BasicView({super.key});

  @override
  State<BasicView> createState() => _BasicViewState();
}

class _BasicViewState extends State<BasicView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) => SttViewmodel()..initSpeechState(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: () {},
                tooltip: 'Ganti Mode',
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Consumer<SttViewmodel>(
            builder: (context, viewModel, child) {
              viewModel.onStartListeningAnimation = () {
                _animationController.repeat(reverse: true);
              };
              viewModel.onStopListeningAnimation = () {
                _animationController.stop();
                _animationController.reset();
              };
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  _M3MicrophoneButton(
                    isListening: viewModel.isListening,
                    scaleAnimation: _scaleAnimation,
                    opacityAnimation: _opacityAnimation,
                    onTap: viewModel.toggleListening,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _M3TextDisplay(
                    text: viewModel.displayText,
                    isListening: viewModel.isListening,
                  ),
                  
                  if (viewModel.isListening)
                    ValueListenableBuilder<double>(
                      valueListenable: viewModel.soundLevelNotifier,
                      builder: (context, level, child) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: LinearProgressIndicator(
                            value: level / 10.0, // Normalize to 0-1
                            backgroundColor: Colors.grey[300],
                          ),
                        );
                      },
                    ),

                  const Spacer(),
                  
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Agros',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ));
  }
}

class _M3MicrophoneButton extends StatelessWidget {
  const _M3MicrophoneButton({
    required this.isListening,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.onTap,
  });

  final bool isListening;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final activeColor = colorScheme.primary; 
    final inactiveColor = colorScheme.surfaceContainerHigh;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isListening) ...[
          _AnimatedPulse(
            size: 200,
            color: activeColor,
            baseOpacity: 0.2,
            scaleAnimation: scaleAnimation,
            opacityAnimation: opacityAnimation,
          ),
        ],

        SizedBox(
          width: 140,
          height: 140,
          child: IconButton.filled(
            onPressed: onTap,
            style: IconButton.styleFrom(
              backgroundColor: isListening ? activeColor : inactiveColor,
              foregroundColor: isListening ? colorScheme.onPrimary : colorScheme.primary,
              elevation: isListening ? 6 : 0,
            ),
            icon: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: 64,
            ),
          ),
        ),
      ],
    );
  }
}

class _AnimatedPulse extends StatelessWidget {
  const _AnimatedPulse({
    required this.size,
    required this.color,
    required this.baseOpacity,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  final double size;
  final Color color;
  final double baseOpacity;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Container(
          width: size * scaleAnimation.value,
          height: size * scaleAnimation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: baseOpacity * opacityAnimation.value),
          ),
        );
      },
    );
  }
}

class _M3TextDisplay extends StatelessWidget {
  const _M3TextDisplay({
    required this.text,
    required this.isListening,
  });

  final String text;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 2,
        color: colorScheme.surfaceContainerLow, 
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isListening 
                          ? colorScheme.primary 
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}