import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agros/presentation/viewmodels/tts_viewmodel.dart'; 

class TtsView extends StatefulWidget {
  const TtsView({super.key});

  @override
  State<TtsView> createState() => _TtsViewState();
}

class _TtsViewState extends State<TtsView> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan 'watch' untuk rebuild UI saat notifyListeners dipanggil
    final vm = context.watch<TtsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Flutter TTS 4.2.3 MVVM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 50),
        child: Column(
          children: [
            _buildInputSection(),
            _buildButtonSection(vm),
            
            const Divider(),
            
            // Dropdown Engine (Hanya Android)
            if (vm.isAndroid) _buildEngineSection(vm),
            
            _buildLanguageSection(vm),
            
            const SizedBox(height: 20),
            _buildSliders(vm),
            
            if (vm.isAndroid) _buildMaxLengthSection(vm),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: TextField(
        controller: _textController,
        maxLines: 5,
        decoration: const InputDecoration(
          hintText: "Ketik sesuatu untuk dibaca...",
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildButtonSection(TtsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBtn(
            vm.isPlaying ? Colors.grey : Colors.green, 
            Icons.play_arrow, 
            'PLAY', 
            // Disable tombol play jika sedang playing
            vm.isPlaying ? null : () => vm.speak(_textController.text)
          ),
          _buildBtn(Colors.red, Icons.stop, 'STOP', vm.stop),
          _buildBtn(Colors.blue, Icons.pause, 'PAUSE', vm.pause),
        ],
      ),
    );
  }

  Widget _buildEngineSection(TtsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: vm.engine,
        decoration: const InputDecoration(labelText: "Pilih Engine"),
        isExpanded: true,
        items: vm.engines.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: vm.setEngine,
      ),
    );
  }

  Widget _buildLanguageSection(TtsViewModel vm) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: vm.language,
            decoration: const InputDecoration(labelText: "Pilih Bahasa"),
            isExpanded: true,
            // Jika list kosong, tampilkan placeholder
            items: vm.languages.isEmpty 
              ? [] 
              : vm.languages.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
            onChanged: vm.setLanguage,
          ),
          if (vm.isAndroid)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Status Bahasa: ${vm.isCurrentLanguageInstalled ? 'Terinstall ✅' : 'Tidak Terinstall ❌'}",
                style: TextStyle(
                  color: vm.isCurrentLanguageInstalled ? Colors.green : Colors.red,
                  fontSize: 12
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliders(TtsViewModel vm) {
    return Column(
      children: [
        _slider("Volume", vm.volume, vm.updateVolume, Colors.blue),
        _slider("Pitch", vm.pitch, vm.updatePitch, Colors.red, min: 0.5, max: 2.0),
        _slider("Rate", vm.rate, vm.updateRate, Colors.green),
      ],
    );
  }
  
  Widget _buildMaxLengthSection(TtsViewModel vm) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: vm.getMaxInputLength,
            child: const Text('Cek Max Karakter'),
          ),
          Text("${vm.inputLength ?? 0} chars"),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildBtn(Color color, IconData icon, String label, VoidCallback? onTap) {
    return Column(
      children: [
        IconButton.filled(
          style: IconButton.styleFrom(backgroundColor: color.withOpacity(0.1)),
          icon: Icon(icon, color: onTap == null ? Colors.grey : color),
          iconSize: 32,
          onPressed: onTap,
        ),
        Text(label, style: TextStyle(color: onTap == null ? Colors.grey : color, fontSize: 12))
      ],
    );
  }

  Widget _slider(String label, double val, Function(double) onChanged, Color color, {double min = 0.0, double max = 1.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$label: ${val.toStringAsFixed(1)}", style: const TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: val,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: 10,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}