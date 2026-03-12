import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'di/injection.dart';
import 'routes/app_router.dart';
import 'features/lecture_notes/presentation/bloc/note_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // โหลดตัวแปรสภาพแวดล้อมจากไฟล์ .env (ถ้ามี)
  await dotenv.load(fileName: ".env"); // เปลี่ยนเป็น .env ในโปรเจคจริง

  // เรียกใช้งาน Dependency Injection ก่อนแอปเริ่ม
  await initDI(); 
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  
  // เรียกใช้ AppRouter ที่เราสร้างไว้
  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // ฉีด BLoC เข้าไปในแอป เพื่อให้ทุกหน้าเรียกใช้ได้
        BlocProvider(create: (_) => sl<NoteBloc>()),
      ],
      child: MaterialApp.router(
        title: 'AI Lecture Notes',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.config(), // ตั้งค่า Routing
      ),
    );
  }
}