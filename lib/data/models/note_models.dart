class NoteModel {
  final int? id;
  final String title;
  final String content;
  final String summary;
  final String createdAt;
  final int? position; // for ordering

  NoteModel({this.id, required this.title, required this.content, required this.summary, required this.createdAt, this.position});

  // แปลงจาก Map (จาก DB) มาเป็น Object
  factory NoteModel.fromMap(Map<String, dynamic> json) => NoteModel(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    summary: json['summary'],
    createdAt: json['created_at'],
    position: json['position'],
  );

  // แปลงจาก Object เป็น Map (เพื่อเก็บลง DB)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'summary': summary,
    'created_at': createdAt,
    'position': position,
  };
}