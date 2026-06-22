import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:planly/core/services/secure_storage_service.dart';

class AICompanionService {
  GenerativeModel? _model;
  List<Content> _chatHistory = [];
  String? _currentContextText;

  bool get hasApiKey => _model != null;

  AICompanionService();

  Future<void> initialize() async {
    final secureStorage = SecureStorageService();
    final storedKey = await secureStorage.getGeminiApiKey();
    final envKey = dotenv.env['GEMINI_API_KEY'];
    final apiKey = storedKey ?? envKey ?? '';

    if (apiKey.isNotEmpty) {
      _model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: apiKey,
      );
    }
  }

  Future<void> saveApiKey(String key) async {
    await SecureStorageService().saveGeminiApiKey(key);
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: key,
    );
  }

  /// Ekstraksi Audio dari Video menjadi WAV 16kHz Mono menggunakan FFmpeg
  Future<String?> extractAudioToWav(String videoPath) async {
    try {
      final outPath = '${videoPath}_extracted.wav';
      final file = File(outPath);
      if (await file.exists()) {
        await file.delete();
      }

      final command = '-y -i "$videoPath" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$outPath"';
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        return outPath;
      } else {
        final logs = await session.getLogs();
        debugPrint('FFmpeg Extraction failed: $logs');
        return null;
      }
    } catch (e) {
      debugPrint('Error extracting audio: $e');
      return null;
    }
  }

  /// Memproses file (Video -> Audio WAV -> Gemini)
  /// Mengembalikan JSON String persis seperti web AICompanionService.ts
  Future<String?> processLectureFile(String filePath) async {
    try {
      String wavPath = filePath;
      if (!filePath.toLowerCase().endsWith('.wav')) {
        final extracted = await extractAudioToWav(filePath);
        if (extracted == null) throw Exception('Gagal mengekstrak audio dari video');
        wavPath = extracted;
      }

      final fileBytes = await File(wavPath).readAsBytes();
      
      final prompt = '''
Anda adalah asisten AI Planly untuk materi kuliah. 
Analisis transkripsi audio ini secara komprehensif.

KEMBALIKAN HANYA OBJEK JSON VALID dengan struktur berikut TANPA FORMATTING MARKDOWN atau teks lain:
{
  "transcript": "Transkrip lengkap yang rapi dan terstruktur dari audio",
  "chapters": [
    {"timestamp": "00:00:00", "title": "Judul Bab", "summary": "Ringkasan bab"}
  ],
  "takeaways": ["Poin penting 1", "Poin penting 2"],
  "enrichment": {
    "keyTerms": [
      {"term": "Istilah", "definition": "Definisi istilah berdasarkan konteks"}
    ],
    "suggestedReading": [
      {"title": "Judul Referensi", "reason": "Alasan mengapa relevan"}
    ]
  }
}
''';

      final content = [
        Content.multi([
          DataPart('audio/wav', fileBytes),
          TextPart(prompt),
        ])
      ];

      final response = await _model!.generateContent(content);
      
      if (response.text != null) {
        String resultText = response.text!.trim();
        if (resultText.startsWith('```json')) {
          resultText = resultText.replaceAll('```json', '');
          resultText = resultText.replaceAll('```', '');
        }
        
        // Coba parse untuk validasi JSON
        final parsed = jsonDecode(resultText.trim());
        
        // Simpan konteks untuk chat
        _currentContextText = parsed['transcript'];
        _chatHistory.clear();
        
        return jsonEncode(parsed);
      }
      return null;
    } catch (e) {
      debugPrint('AI Companion processing error: $e');
      return null;
    }
  }

  /// Interaksi Chat Context-Aware
  Future<String> chatWithLectureContext(String userMessage) async {
    try {
      if (_currentContextText == null) {
        return "Saya belum memiliki konteks materi. Silakan unggah dan proses video perkuliahan terlebih dahulu.";
      }

      if (_chatHistory.isEmpty) {
        _chatHistory.add(Content.text(
          "Anda adalah asisten akademik super pintar. Jawab pertanyaan mahasiswa Murni Berdasarkan materi berikut:\n\n$_currentContextText\n\nJika pertanyaan diluar konteks materi, tolak dengan sopan."
        ));
        _chatHistory.add(Content.model([TextPart("Baik, saya mengerti. Silakan berikan pertanyaan Anda.")]));
      }

      _chatHistory.add(Content.text(userMessage));

      final response = await _model!.generateContent(_chatHistory);

      if (response.text != null) {
        _chatHistory.add(Content.model([TextPart(response.text!)]));
        return response.text!;
      }
      return "Maaf, saya tidak dapat merespons saat ini.";
    } catch (e) {
      debugPrint('Chat error: $e');
      return "Terjadi kesalahan saat menghubungi AI. Pastikan internet Anda stabil.";
    }
  }
}
