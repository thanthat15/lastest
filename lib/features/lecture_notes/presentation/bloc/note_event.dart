import 'package:equatable/equatable.dart';
import 'package:lab2/features/lecture_notes/domain/entities/note.dart';
import '../../../domain/entities/note.dart';

abstract class NoteEvent extends Equatable {
  const NoteEvent();
  @override
  List<Object> get props => [];
}

class LoadNotesEvent extends NoteEvent {}

class SaveNoteEvent extends NoteEvent {
  final Note note;
  const SaveNoteEvent(this.note);
  @override
  List<Object> get props => [note];
}

class SummarizeTextEvent extends NoteEvent {
  final String text;
  const SummarizeTextEvent(this.text);
  @override
  List<Object> get props => [text];
}