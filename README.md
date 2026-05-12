# 📱 SociaSync

Aplikasi mobile all-in-one untuk kreator konten dan pengelola media sosial — rencanakan, buat, jadwalkan, dan pantau konten dari satu tempat. Dibangun dengan **Flutter** di sisi mobile dan **Django REST Framework** di sisi backend, dilengkapi dukungan **AI (Google Gemini)** untuk ide konten, script, caption, hashtag, dan chatbot strategi konten.

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|---|---|
| 🔐 **Autentikasi** | Register, login, refresh token JWT, profil, dan reset password |
| 📊 **Dashboard** | Ringkasan akun, status koneksi Instagram & TikTok, akses cepat ke fitur |
| 📅 **Kalender Konten** | Tampilan mingguan, bulanan, tahunan, dan manajemen jadwal posting |
| 🤖 **Content Generator AI** | Generate ide, script, caption, dan hashtag berbasis Google Gemini |
| 💬 **Chatbot AI** | Asisten percakapan untuk strategi dan produksi konten |
| 📲 **Integrasi Sosmed** | Pengambilan data Instagram dan TikTok via modul scraper backend |
| 🔔 **Notifikasi & Reminder** | Pengingat aktivitas, daftar notifikasi, unread count, dan pengaturan |
| 👤 **Profil Pengguna** | Kelola akun, gambar profil, bantuan, dan pengaturan notifikasi |

---

## 🛠️ Tech Stack

| Area | Teknologi |
|---|---|
| **Mobile App** | Flutter, Dart, Material 3 |
| **State & Storage** | `shared_preferences`, service layer berbasis HTTP |
| **Chart & Media** | `fl_chart`, `image_picker` |
| **Notifikasi Lokal** | `flutter_local_notifications`, `timezone` |
| **Backend API** | Django 5.2, Django REST Framework |
| **Autentikasi** | Simple JWT |
| **Database** | SQLite (pengembangan lokal) |
| **AI** | Google Gemini API |
| **API Testing** | Postman collection/environment |

---

## 📁 Struktur Proyek

```
MobileApp_Sociasync/
├── backend/
│   └── backend_drf/
│       ├── backend_drf/        # Konfigurasi project Django
│       ├── users/              # Auth, profil, reset password
│       ├── schedules/          # Jadwal kalender konten
│       ├── notifications/      # Notifikasi dan pengaturan
│       ├── reminder_msg/       # Reminder/pengingat
│       ├── insta_scraper/      # Integrasi scraper Instagram
│       ├── tiktok_scraper/     # Integrasi scraper TikTok
│       ├── content_gen/        # Generator konten berbasis AI
│       ├── chatbot_AI/         # Chatbot AI
│       └── manage.py
└── frontend/
    └── sociasync_app/
        ├── lib/
        │   ├── config/         # Konfigurasi base URL API
        │   ├── screens/        # Halaman aplikasi
        │   ├── services/       # Client API dan service lokal
        │   └── widgets/        # Komponen UI reusable
        ├── assets/             # Gambar dan ikon aplikasi
        └── test/               # Widget/unit test Flutter
```

---

## ⚙️ Cara Menjalankan

### Prasyarat

Pastikan perangkat pengembangan sudah memiliki:
- Flutter SDK (Dart SDK `^3.10.4`)
- Python 3.11+
- Android Studio atau emulator/device Android
- Gemini API Key (untuk fitur AI)
- Apify API Token (untuk fitur scraping Instagram/TikTok)

---

### 🔧 Setup Backend

```bash
# Masuk ke folder backend
cd backend/backend_drf

# Buat dan aktifkan virtual environment
python -m venv .venv
.venv\Scripts\activate        # Windows
# source .venv/bin/activate   # macOS/Linux

# Install dependensi
pip install django djangorestframework djangorestframework-simplejwt \
    django-cors-headers python-dotenv google-generativeai pillow

# Salin file environment dan isi kredensial
copy .env.example .env
```

Isi file `.env` dengan konfigurasi berikut:

```env
GEMINI_API_KEY=your_gemini_api_key
APIFY_API_TOKEN=your_apify_token
DJANGO_EMAIL_BACKEND=django.core.mail.backends.console.EmailBackend
DEFAULT_FROM_EMAIL=noreply@sociasync.local
```

```bash
# Jalankan migrasi dan server
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

Backend akan berjalan di `http://127.0.0.1:8000`.

---

### 📱 Setup Frontend

```bash
# Masuk ke folder Flutter
cd frontend/sociasync_app

# Install package
flutter pub get

# Jalankan aplikasi
flutter run
```

Base URL API otomatis dikonfigurasi berdasarkan platform:

| Platform | Base URL Default |
|---|---|
| Android Emulator | `http://10.0.2.2:8000` |
| Web | Host halaman web dengan port `8000` |
| Desktop / iOS Simulator | `http://127.0.0.1:8000` |

Untuk mengganti base URL saat runtime:

```bash
flutter run --dart-define=API_BASE_URL=http://your-host:8000
```

---

## 🔌 Endpoint API

| Modul | Prefix | Keterangan |
|---|---|---|
| Auth | `/api/auth/` | Login, register, profil, reset password, refresh token |
| Schedules | `/api/schedules/` | CRUD jadwal konten |
| Notifications | `/api/notifications/` | Daftar, unread count, read all, settings |
| Instagram | `/api/instagram/` | Koneksi dan data Instagram |
| TikTok | `/api/tiktok/` | Koneksi dan data TikTok |
| Content Generator | `/api/content-gen/` | Generate ide, script, caption, hashtag, saved content |
| Chatbot | `/api/chat/` | Percakapan dengan chatbot AI |
| Reminders | `/api/reminders/` | Daftar, buat, update, dan complete reminder |

---

## 🧪 Testing

```bash
# Flutter test
cd frontend/sociasync_app
flutter test

# Django test
cd backend/backend_drf
python manage.py test
```

---


## 👥 Contributors

Proyek ini dikembangkan sebagai tugas kelompok — *[Grace L.R. Pangaribuan, Vincent Chou dan Gracello Sihombing]*.
