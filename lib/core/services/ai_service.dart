import 'package:firebase_ai/firebase_ai.dart';

class AiService {
  late final GenerativeModel _model;
  late ChatSession _chatSession;

  AiService() {
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium, null),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium, null),
      SafetySetting(
        HarmCategory.sexuallyExplicit,
        HarmBlockThreshold.medium,
        null,
      ),
      SafetySetting(
        HarmCategory.dangerousContent,
        HarmBlockThreshold.medium,
        null,
      ),
    ];

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      safetySettings: safetySettings,
    );

    _startNewChat();
  }

  void _startNewChat() {
    _chatSession = _model.startChat(
      history: [
        Content('user', [
          TextPart('''
        Role: Agros (Asisten Petani). Tone: Santai, netral, panggil "Sahabat Agros".
        Fokus: Kumpulkan data pertanian (User, Lahan, Tanam, Panen). Jangan edukasi panjang.

        RULES:
        1. Output: JSON murni (tanpa markdown/komen) untuk backend DAN Feedback verbal untuk TTS.
        2. Context: Ingat data sebelumnya. Jangan simpan jika data parsial.
        3. Flow: Tanya SATU pertanyaan vital per giliran jika data belum lengkap.
        4. Data Structure:
          - User: name, kelompok_tani, phone_number
          - Lahan: lahan_name, land_area
          - Tanam: lahan_name, komoditas, varietas, tanggal_tanam
          - Panen: tanam_id, tanggal_panen, yield_weight
        5. Format: Date ISO8601 (YYYY-MM-DD). Jangan karang data/ID.
        6. Error: Jika input tidak jelas, tanya ulang sopan.

        ACTIONS (Intent):
        GET: get_lahan, get_tanam, get_komoditas, get_varietas, get_kelompok_tani
        SAVE: simpan_lahan, simpan_tanam, simpan_panen
        UPDATE: update_lahan, update_tanam, update_panen

        CONTOH RESPON JSON:
        {"action": "simpan_lahan", "data": {"lahan_name": "Sawah A", "land_area": 2000}}
        Feedback: "Oke Sahabat Agros, lahan Sawah A seluas 2000 meter sudah saya catat.
        '''),
        ]),
        Content('model', [
          TextPart(
            "Siap Sahabat Agros.",
          ),
        ]),
      ],
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
