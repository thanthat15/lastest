import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../domain/entities/note.dart';
import '../../../../data/local/database_helper.dart';
import '../../../../data/models/note_models.dart';
import '../bloc/note_bloc.dart';
import '../bloc/note_event.dart';
import '../bloc/note_state.dart';

@RoutePage()
class NoteFormPage extends StatefulWidget {
  final NoteModel? note;
  const NoteFormPage({super.key, this.note});

  @override
  State<NoteFormPage> createState() => _NoteFormPageState();
}

class _NoteFormPageState extends State<NoteFormPage> {
  // 🌟 Form & Validation: ใช้ GlobalKey สำหรับจัดการ Form
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _summaryResult = '';
  // Image picker + temporary file for manual processing
  final ImagePicker _picker = ImagePicker();
  File? _image;

  @override
  void initState() {
    super.initState();
    // ถ้ามี note ที่ส่งเข้ามา แปลว่าเป็นการแก้ไข ให้เติมค่าลงใน controller
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _summaryResult = widget.note!.summary;
    }
  }

  // 🌟 On-device ML: ฟังก์ชันสแกนข้อความจากภาพ (ML Kit)
  Future<void> _scanTextFromImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // เปลี่ยนเป็น ImageSource.camera ได้
    
    if (pickedFile != null) {
    final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // รองรับภาษาอังกฤษ (หากต้องการไทยต้องอัปเดตโมเดล)
      
      try {
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        setState(() {
          // นำข้อความที่สแกนได้มาใส่ในช่อง Content อัตโนมัติ
          _contentController.text = recognizedText.text;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('สแกนข้อความไม่สำเร็จ')));
      } finally {
        textRecognizer.close();
      }
    }
  }

  // Additional helper: pick image into a `File` and process it
  Future<void> _pickImage() async {
    final XFile? selectedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) {
      setState(() {
        _image = File(selectedImage.path);
      });
      // พอได้รูปแล้ว สั่งสแกนต่อทันที
      _processImageForText(_image!);
    }
  }

  // Process a File with ML Kit and put extracted text into the content controller
  Future<void> _processImageForText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin); // ใช้ latin สำหรับภาษาอังกฤษ

    try {
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // ดึงข้อความทั้งหมดที่แกะได้มาต่อกัน
      String extractedText = recognizedText.text;

      setState(() {
        // เอาข้อความที่ได้ไปใส่ในช่องเนื้อหาโน้ต (TextField)
        _contentController.text = extractedText; 
      });
    } catch (e) {
      print("Error scanning text: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('สแกนข้อความไม่สำเร็จ')));
    } finally {
      textRecognizer.close();
    }
  }

  void _saveNote() {
    // 🌟 Validation: ตรวจสอบว่ากรอกข้อมูลครบหรือไม่
    if (_formKey.currentState!.validate()) {
      if (_summaryResult.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณาให้ AI สรุปข้อความก่อนบันทึก')));
        return;
      }

      final newNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        content: _contentController.text,
        summary: _summaryResult,
        createdAt: DateTime.now(),
      );

      context.read<NoteBloc>().add(SaveNoteEvent(newNote));
      context.router.pop(); // บันทึกเสร็จให้เด้งกลับไปหน้ารวม
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('สร้างโน้ตใหม่')),
      body: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteSummarized) {
            setState(() { _summaryResult = state.summaryText; });
          } else if (state is NoteError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'หัวข้อโน้ต', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'ห้ามเว้นว่าง' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: 'เนื้อหา (พิมพ์เองหรือสแกนจากภาพ)', border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? 'ห้ามเว้นว่าง' : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _scanTextFromImage,
                  icon: const Icon(Icons.document_scanner),
                  label: const Text('สแกนข้อความจากรูปภาพ (ML Kit)'),
                ),
                const Divider(height: 30),
                
                // ปุ่มเรียก Gemini API
                ElevatedButton.icon(
                  onPressed: () {
                    if (_contentController.text.isNotEmpty) {
                      context.read<NoteBloc>().add(SummarizeTextEvent(_contentController.text));
                    }
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('สรุปข้อความด้วย AI'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple.shade100),
                ),
                
                if (state is NoteLoading) const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),

                // 🌟 Implicit Animation: กล่องข้อความสรุปจะค่อยๆ ปรากฏขึ้นมาอย่างนุ่มนวล
                AnimatedSize(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: _summaryResult.isEmpty
                      ? const SizedBox.shrink()
                      : Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('สรุปจาก AI:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                              const SizedBox(height: 8),
                              Text(_summaryResult),
                            ],
                          ),
                        ),
                ),
                
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () async {
                    // ใช้ Form validation ก่อนบันทึก
                    if (!_formKey.currentState!.validate()) return;

                    final note = NoteModel(
                      id: widget.note?.id,
                      title: _titleController.text,
                      content: _contentController.text,
                      summary: _summaryResult.isEmpty ? 'ยังไม่มีบทสรุป (ต้องใช้เน็ต)' : _summaryResult,
                      createdAt: widget.note?.createdAt ?? DateTime.now().toIso8601String(),
                    );

                    if (widget.note == null) {
                      await DatabaseHelper.instance.create(note);
                    } else {
                      await DatabaseHelper.instance.update(note);
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('บันทึกโน้ตลงเครื่องสำเร็จ! (Offline Ready)')),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('บันทึกโน้ต'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}