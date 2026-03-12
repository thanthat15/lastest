# lab2

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
 
 # 📝 AI Lecture Notes

แอปพลิเคชันจดโน้ตอัจฉริยะที่ผสานเทคโนโลยี **On-device Machine Learning** และ **Generative AI** เข้าด้วยกัน ถูกออกแบบมาด้วยสถาปัตยกรรมแบบ **Offline-First** เพื่อให้ผู้ใช้สามารถจัดการโน้ตและดึงข้อความจากภาพได้ทุกที่ทุกเวลา แม้ไม่มีการเชื่อมต่ออินเทอร์เน็ต

---

## 🎬 Demonstration Video
*(สามารถรับชมวิดีโอสาธิตการทำงานของแอปพลิเคชัน โหมด Offline & Online, UI Animation และการรัน Test ได้ที่ลิงก์ด้านล่างนี้)*
👉 **[ใส่ลิงก์ YouTube หรือ Google Drive ของวิดีโอพรีเซนต์ที่นี่]**

---

## ✨ Features (ฟีเจอร์หลัก)

- 📴 **Offline-First Data Management:**
  - สร้าง, อ่าน, แก้ไข และลบโน้ตได้ตลอดเวลา ข้อมูลทั้งหมดจะถูกบันทึกลงฐานข้อมูล SQLite ภายในเครื่อง (Local Storage)
  - ข้อมูลและบทสรุปที่เคยทำไว้จะยังคงอยู่ครบถ้วนแม้เปิดแอปพลิเคชันในโหมดเครื่องบิน (Airplane Mode)
- 📸 **On-device Smart OCR:**
  - ดึงข้อความจากรูปภาพ (Text Recognition) ผ่านกล้องหรือรูปถ่ายด้วย **Google ML Kit** ซึ่งทำงานประมวลผลบนตัวเครื่อง 100% โดยไม่ต้องใช้อินเทอร์เน็ต
- 🤖 **AI Summarization:**
  - สรุปเนื้อหาเลกเชอร์ที่ยืดยาวให้กลายเป็นบทคัดย่อที่กระชับและเข้าใจง่าย ด้วยพลังของ **Google Gemini AI** (ฟีเจอร์นี้ต้องการอินเทอร์เน็ต)
- 🎨 **Interactive & Modern UI:**
  - **Reorderable List:** กดค้างที่รายการโน้ตเพื่อลากสลับตำแหน่งได้ตามต้องการ
  - **Swipe to Delete & Undo:** ปัดซ้ายเพื่อลบโน้ตอย่างรวดเร็ว (Dismissible) พร้อมระบบแจ้งเตือนที่มีปุ่ม "เลิกทำ (Undo)" เพื่อกู้คืนข้อมูล
  - **Form Validation:** ตรวจสอบความถูกต้องของข้อมูลก่อนบันทึกลงฐานข้อมูล

---

## 🏗️ Architecture & Technologies (สถาปัตยกรรมและเทคโนโลยี)

แอปพลิเคชันนี้พัฒนาด้วย **Flutter** โดยใช้โครงสร้างที่แยกส่วนการทำงานอย่างชัดเจน:
- **UI Layer (Presentation):** จัดการหน้าจอและ UI ด้วย Flutter Widgets และ `setState`
- **Data Layer (Local Storage):** ใช้แพ็กเกจ `sqflite` ในการสร้างฐานข้อมูล RDBMS สำหรับรองรับโหมด Offline
- **Machine Learning Layer:** ใช้ `google_mlkit_text_recognition` ดึงตัวอักษรจากภาพแบบ Local
- **Cloud AI Layer:** เชื่อมต่อผ่าน `google_generative_ai` (Gemini API) เพื่อวิเคราะห์ภาษา
- **Security:** ใช้ `flutter_dotenv` เพื่อจัดการ Environment Variables และซ่อน API Key อย่างปลอดภัย (No API Keys in Code)

---

## 🚀 Getting Started (วิธีการติดตั้งและเปิดใช้งานโปรเจกต์)

เพื่อให้สามารถรันโปรเจกต์นี้ได้อย่างสมบูรณ์ กรุณาทำตามขั้นตอนดังต่อไปนี้:

### 1. Clone Repository
ดึง Source Code ลงมาที่เครื่องของคุณ:
```bash
git clone [https://github.com/ใส](https://github.com/ใส)่ชื่อผู้ใช้/ใส่ชื่อโปรเจกต์.git
cd ใส่ชื่อโฟลเดอร์โปรเจกต์

### 2. Install Dependencies (ดาวน์โหลดแพ็กเกจ)
flutter pub get

### 3. Environment Setup (การตั้งค่า API Key)
สร้างไฟล์ใหม่ชื่อ .env ไว้ที่โฟลเดอร์ Root ของโปรเจกต์ (ระดับเดียวกับ pubspec.yaml)
นำ Gemini API Key ของคุณมาใส่ในไฟล์ .env
    GEMINI_API_KEY=ใส่_API_KEY_ของคุณที่นี่

### 4. Test&Run the Application
flutter test
flutter run

