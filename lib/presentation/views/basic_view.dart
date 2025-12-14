import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:agros/presentation/viewmodels/stt_viewmodel.dart';
import 'package:agros/presentation/viewmodels/tts_viewmodel.dart';

import 'package:agros/presentation/widgets/toggle_switch.dart';
import 'package:agros/presentation/widgets/microphone_icon.dart';


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
                      // TODO: Implementasi logika pindah mode di masa depan
                    },
                  ),
                ],
              ),

              const Spacer(flex: 1),

              Consumer2<SttViewmodel, TtsViewModel>(
                builder: (context, sttVm, ttsVm, child) {
                  String textToShow = "Hi! Sahabat Agros!";

                  if (sttVm.isListening) {
                    textToShow = sttVm.lastWords.isEmpty ? "Mendengarkan..." : sttVm.lastWords;
                  } else if (ttsVm.isPlaying) {
                    textToShow = "Agros sedang menjelaskan..."; 
                  } else if (sttVm.lastWords.isNotEmpty) {
                    textToShow = sttVm.lastWords;
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

              Consumer2<SttViewmodel, TtsViewModel>(
                builder: (context, sttVm, ttsVm, child) {
                  bool isBusy = sttVm.isListening; 

                  return MicropohoneIcon(
                    isListening: isBusy,
                    onTap: () {
                      if (ttsVm.isPlaying) {
                        ttsVm.stop(); 
                      } 
                      else if (sttVm.isListening) {
                        sttVm.stopListening();
                      } 
                      else {
                        sttVm.startListening();
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