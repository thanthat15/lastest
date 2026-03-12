import 'package:equatable/equatable.dart';

// คลาสแม่สำหรับจัดการ Error ทั้งหมดของแอป
abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Error เวลามีปัญหาเรื่องต่อเน็ต หรือ API ของ AI พัง
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

// Error เวลามีปัญหาตอนเซฟลงฐานข้อมูลในเครื่อง (SQLite/Isar)
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}