import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/note.dart';

abstract class NoteRepository {
  // 1. ดึงโน้ตทั้งหมดจากฐานข้อมูลในเครื่อง (Offline-first)
  Future<Either<Failure, List<Note>>> getNotes();

  // 2. บันทึกโน้ตลงฐานข้อมูล
  Future<Either<Failure, void>> saveNote(Note note);

  // 3. ส่งข้อความยาวๆ ไปให้ AI สรุป (เรียก LLM API)
  // ฝั่งขวา (สำเร็จ) จะคืนค่ากลับมาเป็น String (ข้อความที่สรุปแล้ว)
  Future<Either<Failure, String>> summarizeText(String text);
}