import 'package:agros/presentation/viewmodels/assistant_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agros/presentation/widgets/toggle_switch.dart';
import 'package:agros/presentation/widgets/microphone_icon.dart';

import 'package:agros/presentation/views/advance_view.dart';


class BasicView extends StatefulWidget {
  const BasicView({super.key});

  @override
  State<BasicView> createState() => _BasicViewState();
}

class _BasicViewState extends State<BasicView> {
  bool isBasicMode = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AGROS',
                    style: GoogleFonts.baloo2(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary, 
                      letterSpacing: 2.0,
                    ),
                  ),
                  ToggleSwitch(
                    value: isBasicMode,
                    onChanged: (val) {
                      setState(() => isBasicMode = val);
                      if (val == false) {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, anim1, anim2) => const AdvanceView(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),

              const Spacer(flex: 1),

              Consumer<AssistantViewModel>(
                builder: (context, assistantVm, child) {
                  String textToShow = "Hi! Sahabat Agros!";

                  switch (assistantVm.state) {
                    case AgrosState.standby:
                      textToShow = "Panggil 'Halo Agros'...";
                      break;
                    case AgrosState.listeningCommand:
                      textToShow = "Mendengarkan...";
                      break;
                    case AgrosState.processing:
                      textToShow = "Agros sedang berpikir...";
                      break;
                    case AgrosState.speaking:
                      if (assistantVm.lastResponse.isNotEmpty) {
                        textToShow = assistantVm.lastResponse;
                      } else {
                        textToShow = "Agros menjawab...";
                      }
                      break;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      textToShow,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),

              const Spacer(flex: 1),

              Consumer<AssistantViewModel>(
                builder: (context, assistantVm, child) {
                  bool isBusy = assistantVm.state != AgrosState.standby;

                  return MicropohoneIcon(
                    isListening: isBusy,
                    onTap: () {
                      if (assistantVm.state == AgrosState.standby) {
                        assistantVm.manualStartListening();
                      } 
                      else if (assistantVm.state == AgrosState.listeningCommand) {
                        assistantVm.manualStopListening();
                      } 
                      else {
                        assistantVm.startStandbyMode();
                      }
                    },
                  );
                },
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}