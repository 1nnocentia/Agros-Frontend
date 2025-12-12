import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  AiService() {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium, HarmBlockMethod.probability),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium, HarmBlockMethod.probability),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium, HarmBlockMethod.probability),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium, HarmBlockMethod.probability),
    ];

    _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash', safetySettings: safetySettings);

    _startNewChat();
  }

  void _startNewChat() {
    _chatSession = _model.startChat(
      history: [
        Content('user', [TextPart("jbijebfjif")]),
        Content('model', [TextPart("jbijebfjif")]),
      ]
    );
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final contentObject = Content('user', [TextPart(userMessage)]);
      final response = await _chatSession.sendMessage(contentObject);
      return response.text ?? "Maaf, saya tidak mengerti, bolehkah di ulang?.";

    } catch (e) {
      return "Terjadi kesalahan AI: $e";
    }
  }
}