import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/note.dart';

@RoutePage()
class NoteDetailPage extends StatelessWidget {
  final Note note; // 🌟 AutoRoute: รับพารามิเตอร์

  const NoteDetailPage({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(note.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              // 🌟 Explicit Animation (Hero): คู่กับ Hero ใน NoteListPage
              child: Hero(
                tag: 'note-icon-${note.id}',
                child: const Icon(Icons.note_alt, size: 100, color: Colors.deepPurple),
              ),
            ),
            const SizedBox(height: 20),
            const Text('สรุปเนื้อหา (AI):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.purple.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(note.summary, style: const TextStyle(fontSize: 16)),
            ),
            const Divider(height: 40),
            const Text('เนื้อหาต้นฉบับ:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(note.content),
          ],
        ),
      ),
    );
  }
}