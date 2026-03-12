import 'package:equatable/equatable.dart';

class Note extends Equatable {
  final String id;
  final String title;       // หัวข้อโน้ต
  final String content;     // ข้อความดิบที่สแกนได้จาก ML Kit (OCR)
  final String summary;     // ข้อความสวยๆ ที่ Gemini สรุปให้แล้ว
  final DateTime createdAt; // วันที่บันทึก

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.summary,
    required this.createdAt,
  });

  // ตรงนี้ช่วยให้ Flutter รู้ว่าโน้ต 2 แผ่นเหมือนกันไหม (มีประโยชน์ตอนทำ Test)
  @override
  List<Object?> get props => [id, title, content, summary, createdAt];
}