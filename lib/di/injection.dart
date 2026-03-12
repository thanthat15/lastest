import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../features/lecture_notes/data/datasources/local/note_local_data_source.dart';
import '../features/lecture_notes/data/datasources/remote/note_remote_data_source.dart';
import '../features/lecture_notes/data/repositories/note_repository_impl.dart';
import '../features/lecture_notes/domain/repositories/note_repository.dart';
import '../features/lecture_notes/presentation/bloc/note_bloc.dart';

final sl = GetIt.instance; // sl ย่อมาจาก Service Locator

Future<void> initDI() async {
  // 1. External Packages (เปิดฐานข้อมูล, สร้าง Dio)
  final documentsDirectory = await getApplicationDocumentsDirectory();
  final path = join(documentsDirectory.path, 'notes.db');
  final database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('CREATE TABLE notes (id TEXT PRIMARY KEY, title TEXT, content TEXT, summary TEXT, createdAt TEXT)');
    },
  );
  
  await Hive.initFlutter();
  final cacheBox = await Hive.openBox('ai_cache');
  
  final dio = Dio();
  // TODO: เพิ่ม Interceptors ตามเกณฑ์บังคับ (เดี๋ยวเรามาเพิ่มทีหลังได้ครับ)
  dio.interceptors.add(LogInterceptor(responseBody: true)); 

  sl.registerLazySingleton(() => database);
  sl.registerLazySingleton(() => cacheBox);
  sl.registerLazySingleton(() => dio);

  // 2. Data Sources
  sl.registerLazySingleton<NoteLocalDataSource>(
    () => NoteLocalDataSourceImpl(database: sl(), cacheBox: sl()),
  );
  sl.registerLazySingleton<NoteRemoteDataSource>(
    () => NoteRemoteDataSourceImpl(dio: sl()),
  );

  // 3. Repository
  sl.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // 4. BLoC (ใช้ Factory เพราะเราอยากได้ Instance ใหม่ทุกครั้งที่เรียกใช้ในหน้า UI)
  sl.registerFactory(() => NoteBloc(repository: sl()));
}