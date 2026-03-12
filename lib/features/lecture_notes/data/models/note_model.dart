import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/note.dart';

// ไฟล์นี้จะถูกสร้างอัตโนมัติเมื่อเรารันคำสั่ง build_runner
part 'note_model.g.dart';

@JsonSerializable()
class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.summary,
    required super.createdAt,
  });

  // ฟังก์ชันแปลง JSON เป็น Object
  factory NoteModel.fromJson(Map<String, dynamic> json) => _$NoteModelFromJson(json);
  
  // ฟังก์ชันแปลง Object เป็น JSON
  Map<String, dynamic> toJson() => _$NoteModelToJson(this);

  // ฟังก์ชันแปลงจาก Entity ของ Domain Layer มาเป็น Model ของ Data Layer
  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      summary: note.summary,
      createdAt: note.createdAt,
    );
  }
}