import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../features/lecture_notes/domain/entities/note.dart';
import '../features/lecture_notes/presentation/pages/note_list_page.dart';
import '../features/lecture_notes/presentation/pages/note_detail_page.dart';
import '../features/lecture_notes/presentation/pages/note_form_page.dart';

part 'app_router.gr.dart'; 

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: NoteListRoute.page, initial: true),
    AutoRoute(page: NoteDetailRoute.page),
    AutoRoute(page: NoteFormRoute.page),
  ];
}