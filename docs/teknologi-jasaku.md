# Daftar Teknologi Jasaku

Dokumentasi teknologi yang digunakan dalam pengembangan platform Jasaku.

---

## 1. Aplikasi Mobile (Flutter)

| Teknologi | Versi | Keperluan |
|---|---|---|
| **Flutter** | 3.7+ | Framework cross-platform (Android & iOS) |
| **Dart** | 3.7+ | Bahasa pemrograman |
| **Material Design 3** | - | Sistem desain UI |

### State Management
| Library | Versi | Keperluan |
|---|---|---|
| **flutter_riverpod** | ^2.5.0 | Manajemen state reaktif |
| **riverpod_annotation** | ^2.3.0 | Anotasi code-gen Riverpod |

### Networking
| Library | Versi | Keperluan |
|---|---|---|
| **dio** | ^5.4.0 | HTTP client (singleton dengan JWT interceptor) |

### Peta & Lokasi
| Library | Versi | Keperluan |
|---|---|---|
| **flutter_map** | ^8.3.0 | Widget peta (OpenStreetMap tiles) |
| **latlong2** | ^0.9.1 | Tipe koordinat geografis |
| **geolocator** | ^11.0.0 | Pelacakan lokasi GPS & permission |
| **OpenRouteService** | - | API arah/rute (butuh API key) |
| **OpenStreetMap** | - | Tile provider peta (gratis) |

### Firebase
| Library | Versi | Keperluan |
|---|---|---|
| **firebase_core** | ^4.11.0 | Inisialisasi Firebase |
| **firebase_auth** | ^6.5.4 | Autentikasi Firebase |
| **firebase_messaging** | ^16.4.0 | Penerima push notification (FCM) |
| **flutter_local_notifications** | ^19.5.0 | Tampilan notifikasi lokal |

### Autentikasi
| Library | Versi | Keperluan |
|---|---|---|
| **google_sign_in** | ^7.2.0 | Login dengan Google OAuth |
| **flutter_secure_storage** | ^9.0.0 | Penyimpanan JWT token terenkripsi |

### Gambar & Media
| Library | Versi | Keperluan |
|---|---|---|
| **image_picker** | ^1.0.7 | Pilih gambar dari kamera/galeri |
| **file_picker** | ^8.0.0 | Pilih file (PDF, gambar) |
| **cached_network_image** | ^3.3.0 | caching & loading gambar |
| **flutter_svg** | ^2.2.0 | Rendering file SVG |
| **flutter_image_compress** | ^2.1.0 | Kompresi gambar sebelum upload |
| **camera** | ^0.11.1 | Akses kamera (untuk OCR/liveness) |

### Machine Learning (On-device)
| Library | Versi | Keperluan |
|---|---|---|
| **google_mlkit_text_recognition** | ^0.14.0 | OCR teks KTP |
| **google_mlkit_face_detection** | ^0.12.0 | Deteksi wajah (liveness check) |
| **google_mlkit_document_scanner** | ^0.4.0 | Pemindaian dokumen |

### Utilitas
| Library | Versi | Keperluan |
|---|---|---|
| **intl** | ^0.20.2 | Format tanggal (locale Indonesia) |
| **path_provider** | ^2.1.0 | Akses direktori sementara/permanen |
| **go_router** | ^13.0.0 | Routing deklaratif |

### Build & Dev Tools
| Tool | Versi | Keperluan |
|---|---|---|
| **build_runner** | ^2.4.0 | Code generation runner |
| **flutter_launcher_icons** | ^0.14.0 | Generasi ikon launcher |
| **Gradle** | 8.10.2 | Build system Android |
| **Android Gradle Plugin** | 8.7.0 | Plugin build Android |
| **Kotlin** | 2.1.10 | Bahasa native Android |
| **NDK** | 27.0.12077973 | Native Development Kit |
| **minSdkVersion** | 23 (Android 6.0) | Versi Android minimum |

---

## 2. Backend API

### Runtime & Bahasa
| Teknologi | Versi | Keperluan |
|---|---|---|
| **Node.js** | 20+ | JavaScript runtime |
| **TypeScript** | ^6.0.2 | JavaScript dengan tipe data |
| **ESNext modules** | - | Sistem modul modern |
| **TSX** | ^4.21.0 | Eksekusi TypeScript (hot reload) |

### Framework
| Teknologi | Versi | Keperluan |
|---|---|---|
| **Express** | ^5.2.1 | Framework HTTP server (v5) |
| **cors** | ^2.8.6 | Cross-Origin Resource Sharing |

### ORM & Database
| Teknologi | Versi | Keperluan |
|---|---|---|
| **Prisma** | ^7.7.0 | Database ORM |
| **@prisma/adapter-pg** | ^7.7.0 | Adapter PostgreSQL untuk Prisma |
| **pg** | ^8.20.0 | PostgreSQL node driver |

### Autentikasi & Keamanan
| Teknologi | Versi | Keperluan |
|---|---|---|
| **jsonwebtoken** | ^9.0.3 | Generate & verifikasi JWT |
| **bcryptjs** | ^3.0.3 | Hashing kata sandi (12 rounds) |
| **google-auth-library** | ^10.6.2 | Verifikasi token Google OAuth |
| **Zod** | ^4.4.3 | Validasi schema request |

### Cloud & Third-Party
| Teknologi | Versi | Keperluan |
|---|---|---|
| **firebase-admin** | ^14.0.0 | Firebase Admin SDK (FCM push notification) |
| **@supabase/supabase-js** | ^2.110.2 | Supabase client (file storage, DB) |
| **axios** | ^1.18.1 | HTTP client untuk pemanggilan face service |
| **multer** | ^2.1.1 | Middleware upload file (10MB limit) |

### API Documentation
| Teknologi | Versi | Keperluan |
|---|---|---|
| **swagger-jsdoc** | ^6.2.8 | Generasi spec Swagger dari JSDoc |
| **swagger-ui-express** | ^5.0.1 | Swagger UI di `/api-docs` |
| **OpenAPI 3.0.0** | - | Standar spesifikasi API |

---

## 3. Face Recognition Service

| Teknologi | Versi | Keperluan |
|---|---|---|
| **Python** | 3.14 | Runtime |
| **Flask** | 3.1.x | Framework web ringan |
| **Gunicorn** | 23.x | WSGI server produksi |
| **InsightFace** | >=1.0, <1.2 | Library face recognition |
| **buffalo_l model** | - | Model analisis wajah (ONNX) |
| **ONNX Runtime** | - | Inferensi neural network (CPU) |
| **OpenCV (cv2)** | 4.11.x | Pemuatan & pemrosesan gambar |
| **NumPy** | >=2.2.0 | Komputasi numerik |
| **Pillow (PIL)** | 11.x | Manipulasi gambar |

---

## 4. Database

| Komponen | Detail |
|---|---|
| **PostgreSQL** | Database utama (via Supabase) |
| **PostGIS** | Ekstensi geospasial (kolom geometry, indeks GiST) |
| **Row-Level Security (RLS)** | kontrol akses di level database |
| **Supabase** | Hosting managed PostgreSQL + Storage |

### Fitur Database
- UUID primary keys (`uuid_generate_v4()`)
- Tipe `geometry` PostGIS untuk query geospasial
- Indeks spatial GiST pada `provider_locations.location`
- Kolom JSONB untuk hasil OCR dan data liveness
- Presisi decimal untuk data finansial
- Field array (portfolio URLs, report attachments)

---

## 5. Hosting & Deployment

| Layanan | Keperluan |
|---|---|
| **Supabase** | Hosting database PostgreSQL + file storage |
| **Render** | Hosting backend API |
| **Firebase** | Push notification (FCM), Google Auth, Analytics |

---

## 6. Documentation & Design Tools

| Teknologi | Keperluan |
|---|---|
| **PlantUML** | Diagram use case, ERD, LDM, CDM, PDM, sequence, activity |
| **Markdown** | Dokumentasi proyek |
| **Swagger/OpenAPI 3.0** | Dokumentasi API interaktif |

---

## 7. Version Control

| Teknologi | Keperluan |
|---|---|
| **Git** | Version control (monorepo) |
| **GitHub** | Hosting repository remote |

---

## Ringkasan

| Kategori | Jumlah |
|---|---|
| Package Flutter/Dart | 30+ dependencies |
| Package Node.js/TypeScript | 14+ dependencies |
| Package Python | 6 |
| Platform Cloud | 3 (Supabase, Render, Firebase) |
| Modul Backend | 12 |
| Modul Flutter Feature | 13 |
| Middleware Backend | 5 |
