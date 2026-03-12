import 'package:equatable/equatable.dart';
import 'package:lab2/features/lecture_notes/domain/entities/note.dart';
import '../../../domain/entities/note.dart';

abstract class NoteState extends Equatable {
  const NoteState();
  @override
  List<Object> get props => [];
}

class NoteInitial extends NoteState {}
class NoteLoading extends NoteState {} // ตอนกำลังโหลดหรือรอ AI ตอบ
class NoteLoaded extends NoteState {
  final List<Note> notes;
  const NoteLoaded(this.notes);
  @override
  List<Object> get props => [notes];
}
class NoteSummarized extends NoteState { // เมื่อ AI สรุปข้อความเสร็จแล้ว
  final String summaryText;
  const NoteSummarized(this.summaryText);
  @override
  List<Object> get props => [summaryText];
}
class NoteError extends NoteState {
  final String message;
  const NoteError(this.message);
  @override
  List<Object> get props => [message];
}