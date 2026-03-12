import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class NoteRemoteDataSource {
  Future<String> summarizeText(String text);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final Dio dio;
  
  // API key is read from environment. Provide it in a local `.env` file
  // with the variable name `GOOGLE_API_KEY` or via --dart-define.
  final String apiKey = dotenv.env['GOOGLE_API_KEY'] ??
      const String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '');

  NoteRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> summarizeText(String text) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('Missing Google API key. Set GOOGLE_API_KEY in .env');
      }

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey',
        data: {
          "contents": [
            {
              "parts": [
                {"text": "สรุปเนื้อหาเลกเชอร์นี้ให้สั้นกระชับ เป็นภาษาไทย อ่านเข้าใจง่าย: $text"}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        // แกะ JSON ที่ตอบกลับมาจาก Gemini API
        return response.data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('เรียก AI ไม่สำเร็จ');
      }
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }
}