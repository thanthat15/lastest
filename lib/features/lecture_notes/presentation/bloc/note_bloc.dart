import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lab2/features/lecture_notes/domain/repositories/note_repository.dart';
import '../../../domain/repositories/note_repository.dart';
import 'note_event.dart';
import 'note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteRepository repository;

  NoteBloc({required this.repository}) : super(NoteInitial()) {
    // โหลดโน้ตทั้งหมด
    on<LoadNotesEvent>((event, emit) async {
      emit(NoteLoading());
      final result = await repository.getNotes();
      result.fold(
        (failure) => emit(NoteError(failure.message)),
        (notes) => emit(NoteLoaded(notes)),
      );
    });

    // บันทึกโน้ต
    on<SaveNoteEvent>((event, emit) async {
      emit(NoteLoading());
      final result = await repository.saveNote(event.note);
      result.fold(
        (failure) => emit(NoteError(failure.message)),
        (_) => add(LoadNotesEvent()), // เซฟเสร็จให้โหลดใหม่
      );
    });

    // ให้ AI สรุปข้อความ
    on<SummarizeTextEvent>((event, emit) async {
      emit(NoteLoading());
      final result = await repository.summarizeText(event.text);
      result.fold(
        (failure) => emit(NoteError(failure.message)),
        (summary) => emit(NoteSummarized(summary)),
      );
    });
  }
}