import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/local/note_local_data_source.dart';
import '../datasources/remote/note_remote_data_source.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource remoteDataSource;
  final NoteLocalDataSource localDataSource;

  NoteRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Note>>> getNotes() async {
    try {
      final localNotes = await localDataSource.getNotes();
      return Right(localNotes); // สำเร็จ ส่งข้อมูลกลับไป
    } catch (e) {
      return Left(DatabaseFailure('ไม่สามารถโหลดข้อมูลโน้ตจากเครื่องได้'));
    }
  }

  @override
  Future<Either<Failure, void>> saveNote(Note note) async {
    try {
      final noteModel = NoteModel.fromEntity(note);
      await localDataSource.saveNote(noteModel);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('บันทึกโน้ตลงเครื่องไม่สำเร็จ'));
    }
  }

  @override
  Future<Either<Failure, String>> summarizeText(String text) async {
    try {
      // 1. ลองเช็คใน Hive (Cache) ก่อนว่าเคยสรุปข้อความนี้ไหม
      final cachedSummary = await localDataSource.getCachedSummary(text);
      if (cachedSummary != null) {
        return Right(cachedSummary); // มีในแคช ส่งกลับเลย ไม่ต้องเปลือง API!
      }

      // 2. ถ้าไม่มีในแคช ค่อยเรียกใช้ Gemini API
      final summary = await remoteDataSource.summarizeText(text);

      // 3. เอาผลลัพธ์จาก AI ไปเก็บลง Hive เป็นแคชเผื่อใช้รอบหน้า
      await localDataSource.cacheSummary(text, summary);

      return Right(summary);
    } catch (e) {
      return Left(ServerFailure('ไม่สามารถเชื่อมต่อกับ AI ได้'));
    }
  }
}