import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab2/features/lecture_notes/domain/entities/note.dart';
import 'package:lab2/features/lecture_notes/presentation/pages/note_detail_page.dart';

void main() {
  testWidgets('NoteDetailPage ควรแสดง หัวข้อ, เนื้อหา และ สรุป ได้อย่างถูกต้อง', (WidgetTester tester) async {
    final tNote = Note(
      id: '1',
      title: 'วิชา Database 101',
      content: 'เนื้อหาเต็มของการเรียน Database วันนี้...',
      summary: 'SQL คือภาษาที่ใช้จัดการฐานข้อมูล',
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NoteDetailPage(note: tNote),
      ),
    );

    final titleFinder = find.text('วิชา Database 101');
    final contentFinder = find.text('เนื้อหาเต็มของการเรียน Database วันนี้...');
    final summaryFinder = find.text('SQL คือภาษาที่ใช้จัดการฐานข้อมูล');

    expect(titleFinder, findsOneWidget); 
    expect(contentFinder, findsOneWidget); 
    expect(summaryFinder, findsOneWidget); 
  });
}