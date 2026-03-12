import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../routes/app_router.dart';
import '../../../../data/local/database_helper.dart';
import '../../../../data/models/note_models.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';
import 'note_form_page.dart';

@RoutePage()
class NoteListPage extends StatefulWidget {
  const NoteListPage({super.key});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  List<NoteModel> _notes = [];
  bool _isLoading = true;

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final list = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = list;
      _isLoading = false;
    });
  }
  Future<void> _saveOrderToDb() async {
    // update positions in DB according to current _notes order
    final updated = <NoteModel>[];
    for (int i = 0; i < _notes.length; i++) {
      final n = _notes[i];
      updated.add(NoteModel(id: n.id, title: n.title, content: n.content, summary: n.summary, createdAt: n.createdAt, position: i));
    }
    await DatabaseHelper.instance.updatePositions(updated);
  }
  @override
  void initState() {
    super.initState();
    // Load notes from local DB
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Lecture Notes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_notes.isEmpty
              ? const Center(child: Text('ยังไม่มีโน้ต กด + เพื่อเพิ่มเลย!'))
              : ReorderableListView.builder(
                  itemCount: _notes.length,
                  onReorder: (int oldIndex, int newIndex) async {
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final NoteModel item = _notes.removeAt(oldIndex);
                      _notes.insert(newIndex, item);
                    });
                    await _saveOrderToDb();
                  },
                  itemBuilder: (context, index) {
                    final note = _notes[index];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red.shade400,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final removedNote = note;
                        // remove from UI immediately
                        setState(() {
                          _notes.removeAt(index);
                        });
                        // delete from DB
                        if (removedNote.id != null) {
                          await DatabaseHelper.instance.deleteById(removedNote.id!);
                        }

                        // show undo snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('ลบโน้ตเรียบร้อยแล้ว'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                // re-insert the note (position will be end)
                                await DatabaseHelper.instance.create(removedNote);
                                await _loadNotes();
                              },
                            ),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: const Icon(Icons.edit_note, color: Colors.deepPurple),
                          title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(note.summary, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                          onTap: () async {
                            // เปิดหน้าแก้ไขด้วย Navigator ปกติ และส่ง NoteModel ไป
                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => NoteFormPage(note: note)),
                            );
                            // รีโหลดข้อมูลเมื่อกลับมาจากหน้าแก้ไข
                            await _loadNotes();
                          },
                        ),
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteFormPage()),
          );
          await _loadNotes(); // reload after returning from add-note
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}