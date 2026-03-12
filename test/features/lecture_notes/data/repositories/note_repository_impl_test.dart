import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lab2/features/lecture_notes/data/datasources/local/note_local_data_source.dart';
import 'package:lab2/features/lecture_notes/data/datasources/remote/note_remote_data_source.dart';
import 'package:lab2/features/lecture_notes/data/repositories/note_repository_impl.dart';

class MockLocalDataSource extends Mock implements NoteLocalDataSource {}
class MockRemoteDataSource extends Mock implements NoteRemoteDataSource {}

void main() {
  late NoteRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    repository = NoteRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tText = 'ข้อความยาวๆ ที่ต้องการสรุป';
  final tSummary = 'สรุปสั้นๆ';

  group('summarizeText', () {
    test('ควรคืนค่าสรุปจาก Cache (Local) ถ้าเคยสรุปข้อความนี้ไปแล้ว โดยไม่เรียก API', () async {
      when(() => mockLocalDataSource.getCachedSummary(tText))
          .thenAnswer((_) async => tSummary);

      final result = await repository.summarizeText(tText);

      expect(result, const Right('สรุปสั้นๆ'));
      
      verify(() => mockLocalDataSource.getCachedSummary(tText)).called(1);
      verifyNever(() => mockRemoteDataSource.summarizeText(any()));
    });
  });
}