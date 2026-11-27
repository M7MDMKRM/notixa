# Notixa - AI Voice Notes, Calendar & Financial Expense Tracker

> **Reconstructed Clean-Room Project**
> Re-engineered from APK `com.camelstudio.notixa` (Version 1.0.6, Build 11).

---

## 📌 نبذة عن المشروع (Overview)

تطبيق **Notixa** هو مساعد ذكي شخصي يجمع بين:
1. **الملاحظات الصوتية بالذكاء الاصطناعي (AI Voice Notes):** تسجيل صوتي واستخراج فوري للمواعيد والمهام والمصروفات عبر الذكاء الاصطناعي وخدمة Deepgram Speech-to-Text.
2. **محفظة المصروفات الذكية (Smart Wallet & Expenses):** تتبع المصروفات (Spent) والإيرادات (Received) بالرسوم البيانية والأيقونات والتصنيفات والعملات المتعددة.
3. **تقويم المواعيد والمنبهات (Calendar & Alarms):** إدارة المواعيد اليومية مع التذكيرات ومنبهات النظام المتقدمة.
4. **الملف الشخصي والأنماط (Profile & Personalization):** دعم الوضع الداكن (Dark Theme) والوضع الفاتح، واللغتين العربية والإنجليزية.

---

## 🏛️ المعمارية البرمجية (Clean Architecture & SOLID)

تمت إعادة بناء التطبيق بالكامل وفق معايير **Clean Architecture** الصارمة ومبادئ **SOLID**:

```
lib/
├── app/
│   ├── app.dart              # Root MaterialApp & Theme/Locale providers
│   ├── di.dart               # Service Locator (GetIt Dependency Injection)
│   └── theme/
│       ├── notixa_palette.dart    # Brand colors & indicators (Received Green #4ADE80, Spent Coral #FF6E84)
│       ├── notixa_theme.dart      # Material 3 Dark & Light theme specs
│       └── notixa_typography.dart # Cairo & Roboto typography
├── core/
│   ├── data/
│   │   ├── local/app_database.dart       # SQLite database (Alarms, Transactions, Meetings)
│   │   ├── network/
│   │   │   ├── app_env.dart              # API URLs (https://api.notixa.ai/api/v1)
│   │   │   └── dio_factory.dart          # HTTP client with timeouts & auth interceptors
│   │   └── storage/token_storage.dart    # FlutterSecureStorage for JWT tokens
│   ├── design_system/                    # Reusable atomic UI components
│   │   ├── notixa_app_bar.dart
│   │   ├── notixa_button.dart
│   │   ├── notixa_pill_tag.dart
│   │   └── notixa_text_field.dart
│   ├── domain/
│   │   └── result.dart                   # Functional Result<T> pattern (Success / Error)
│   └── speech/
│       └── deepgram_speech_service.dart  # Audio recording & STT integration
└── features/
    ├── auth/          # Authentication (Login, Register, Google Sign-in)
    ├── calendar/      # Schedule & TableCalendar with local caching
    ├── home/          # AI Dashboard, Voice recording & AI Note Extraction review
    ├── onboarding/    # 4-step interactive onboarding with illustrations
    ├── profile/       # Profile management, dark/light toggle & Arabic/English
    └── wallet/        # Financial transactions, balance, and categorization
```

---

## 🔍 النتائج المستخرجة من الهندسة العكسية (Reverse-Engineered Endpoints & Assets)

### 1. نقاط الاتصال البرمجية (API Endpoints):
- **Base URL:** `https://api.notixa.ai/api/v1` (Fallback: `http://178.105.190.54/api/v1`)
- **Authentication:**
  - `POST /auth/login`
  - `POST /auth/register`
  - `POST /auth/confirm-email`
  - `POST /auth/google`
  - `POST /auth/forgot-password`
  - `GET  /auth/me`
- **AI Note Processing:**
  - `POST /notes/extract` (AI Extraction from audio/text)
  - `POST /notes/save-data`
- **Wallet & Transactions:**
  - `GET    /transactions`
  - `POST   /transactions`
  - `PUT    /transactions/{id}`
  - `DELETE /transactions/{id}`
- **Calendar & Meetings:**
  - `GET    /meetings`
  - `POST   /meetings`
  - `PUT    /meetings/{id}`
  - `DELETE /meetings/{id}`

### 2. الموارد المستخرجة (Extracted Assets):
- الأيقونة الرسمية: `assets/app_icon.png`
- الشعار: `assets/Logo.png`
- أيقونة الإيرادات: `assets/SVGs/recved_icon.svg` (`#4ADE80`)
- أيقونة المصروفات: `assets/SVGs/spent_icon.svg` (`#FF6E84`)
- شعار Google: `assets/auth/google_logo.svg`
- مؤثرات الوهج البصري: `assets/auth/reg-upper-glow.png`, `login-Cercle.png`

---

## 🚀 كيفية تشغيل المشروع (How to Run)

1. تأكد من تثبيت بيئة **Flutter (SDK >= 3.2.0)**.
2. افتح مجلد المشروع في VS Code أو Android Studio:
   ```bash
   cd C:\Users\M7MD_MKRM\.gemini\antigravity\scratch\notixa_app
   ```
3. ثبّت الحزم والاعتماديات:
   ```bash
   flutter pub get
   ```
4. شغّل التطبيق على محاكي أو جهاز حقيقي:
   ```bash
   flutter run
   ```
