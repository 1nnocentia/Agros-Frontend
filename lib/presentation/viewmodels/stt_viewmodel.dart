import 'package:flutter/material.dart';
import 'package:agros/data/models/stt_model.dart';

class SttViewmodel extends ChangeNotifier {
  final SttModel _model = SttModel();

  bool get _isListening => false;

  String get textResult => _textResult;
  bool get isListening => _isListening;
}