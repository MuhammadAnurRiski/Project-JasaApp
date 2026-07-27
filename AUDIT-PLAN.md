# AUDIT & FIX PLAN — Jasaku

> Terakhir diperbarui: 2026-07-25
> Status: **31 item tercatat, 25 dikerjakan**

---

## Ringkasan Audit

Dilakukan audit besar-besaran terhadap seluruh proyek Jasaku (Flutter app + Backend API + Face Service). Ditemukan **31 issue** yang terbagi dalam 3 prioritas.

---

## PRIORITAS 1 — CRITICAL (Harus fix sekarang)

| # | Item | Deskripsi | Lokasi | Status |
|---|---|---|---|---|
| P1-1 | UI pemilihan Harian/Borongan + pricing unit | Customer tidak bisa pilih sistem pekerjaan. Backend sudah siap (pricing_units, contract_types, service_pricing_units), tapi Flutter UI kosong. | Flutter: `ProviderListScreen`, `DetailProviderSheet`, `CustomerOrdersPage` | ✅ |
| P1-2 | Fix hardcoded "per hari" di order form | Order form selalu tampilkan "per hari" meski pricing unit bisa per_titik, per_m², dll. Label quantity juga salah. | `customer_orders.dart:290,301` | ✅ |
| P1-3 | Upload bukti pembayaran ekstensi | Ekstensi tidak ada upload bukti pembayaran. Customer harus hubungi admin manual. Beda dengan order & custom task yang sudah ada. | Backend: `orders.service.ts`, Flutter: `customer_notifications_page.dart` | ✅ |
| P1-4 | Fix Google login verifikasi status | Google login skip pengecekan status verifikasi provider di Flutter. Provider yang belum verified bisa login. | Flutter auth screens | ✅ |
| P1-5 | Wire admin custom task endpoints | `confirmTaskPayment`, `confirmTaskPayout` sudah ditulis di controller tapi tidak didaftarkan di routes. Dead code. | Backend: `custom-tasks.routes.ts` | ✅ |
| P1-6 | Fix Welcome screen redirect | Welcome screen redirect pending provider ke shell saat network gagal, seharusnya tetap di halaman tunggu. | Flutter: welcome screen | ✅ |

---

## PRIORITAS 2 — HIGH (Fix minggu ini)

| # | Item | Deskripsi | Lokasi | Status |
|---|---|---|---|---|
| P2-1 | Unify warna biru | Dua sistem warna: `AppColors.primary` (#1E40AF) vs hardcode #2563EB di 10+ file. Tidak konsisten. | `customer_home.dart`, `customer_orders.dart`, `customer_provider_list.dart`, dll | ✅ |
| P2-2 | Fix register screen | `customer_register_screen.dart` tampilan kuno, tidak match kualitas login screen. No icons, no validation, no Google signup. | `auth/presentation/screens/customer_register_screen.dart` | ✅ |
| P2-3 | Notification persistence | Tidak ada notification history. Setelah dismiss push notification hilang permanen. Halaman "Notifikasi" cuma extension requests. | Flutter + Backend (tidak ada table notifications) | ⏳ |
| P2-4 | Fix getTodayOrders | `getTodayOrders` tidak include status `in_progress` di filter. | `orders.service.ts:820` | ✅ |
| P2-5 | Fix tracking_map_page | File `tracking_map_page.dart` kosong (0 baris). Bisa crash jika di-import. | `tracking/presentation/pages/tracking_map_page.dart` | ✅ |
| P2-6 | Fix rejection flow | Rejection reason plain-text, membuat edit/resubmit screen tidak usable. Perlu format yang jelas. | Flutter provider auth screens + backend | ✅ |
| P2-7 | Validation middleware registrasi | Tidak ada Zod validation di endpoint registrasi provider. | Backend: `auth.routes.ts` | ✅ |
| P2-8 | Fix Google login error display | Backend tampilkan raw JSON rejection notes ke user. | Backend: `auth.service.ts` | ✅ |
| P2-9 | Fix orange header | `customer_providers_by_category.dart` header pakai orange — off-brand. | `customer_providers_by_category.dart:82` | ✅ |
| P2-10 | Reverse geocoding custom task | Address di custom task berisi "lat, lng" bukan alamat asli. | Flutter: `customer_create_task_page.dart:126` | ✅ |

---

## PRIORITAS 3 — MEDIUM (Next sprint)

| # | Item | Deskripsi | Lokasi | Status |
|---|---|---|---|---|
| P3-1 | Provider schedule cleanup | `provider_schedules` tidak cleanup setelah custom task selesai. Provider tidak bisa ambil order baru. | Backend: custom-tasks service | ✅ |
| P3-2 | Review/rating custom task | Tidak ada mekanisme review untuk custom task provider. | Backend + Flutter | ⏳ |
| P3-3 | Perluas notification badge | Customer badge cuma track extension. Provider badge miss beberapa tipe. | Flutter shells | ⏳ |
| P3-4 | Schedule conflict bidirectional | Order → custom task conflict check tidak ada (sebaliknya sudah ada). | Backend: orders.service.ts | ✅ |
| P3-5 | Cancel-after-accept custom task | Provider tidak bisa cancel setelah accept custom task. | Backend + Flutter | ✅ |
| P3-6 | ProviderModel multiple pricing | `ProviderModel` cuma ambil harga pertama (`pricesList.first`). | `customer_provider_list.dart:1370-1375` | ✅ |
| P3-7 | Attachment validation timing | Validasi attachment (>5) terjadi SETELAH order terbuat. | `orders.service.ts:185-186` | ✅ |
| P3-8 | Completion blocked after 16:00 | Order completion diblokir setelah 16:00 WITA — padahal ekstensi aktif. | `orders.service.ts:662-665` | ✅ |
| P3-9 | Platform fee hardcode | Platform fee 2000 hardcode di backend + Flutter. | `orders.service.ts:154`, `customer_orders.dart:54` | ✅ |
| P3-10 | Hapus debug prints | Debug prints (`print('[FCM]')`, dll) masih ada di production code. | Multiple files | ✅ |
| P3-11 | Payment transactional | Payment creation tidak transactional dengan order creation. | Flutter order flow | ✅ |
| P3-12 | Non-accept transitions atomic | Transisi selain `accepted` tidak atomic (di luar transaction). | `orders.service.ts:647-717` | ✅ |
| P3-13 | Tracking status labels | Status label di tracking page tidak lengkap. | `order_tracking_page.dart:202-208` | ✅ |
| P3-14 | Verifikasi detail custom task mitra | Pastikan detail custom task di mitra app lengkap. | Flutter provider screens | ✅ |
| P3-15 | Route notification taps | Notification tap hanya ke extension, bukan ke screen terkait. | Flutter FCM handler | ⏳ |

---

## Yang Sudah Berjalan Baik ✅

- Order lifecycle (6 status transitions)
- Atomic double-accept prevention
- Extension flow (request → approve → payment → activate)
- Custom task flow dasar
- FCM push notifications
- Provider service pricing backend (7 units, 2 contract types)
- Payment proof upload untuk order & custom task
- Operating hours enforcement
- Swagger API docs
- Login, Home, Profile, Search, Services screens

---

## Catatan

- Todo ini di-generate dari audit besar-besaran tanggal 2026-07-25
- Update status item setelah dikerjakan: `⏳` → `✅`
- Tambahkan catatan perubahan di bagian bawah jika diperlukan

## Changelog

### 2026-07-25 — P1 Complete (6/6)

- **P1-1**: Added pricing unit & contract type selection chips in `ProviderListScreen` + `DetailProviderSheet`. Fetches `GET /services/:serviceId/data`, shows ChoiceChip filters, passes selection to `CustomerOrdersPage`.
- **P1-2**: Fixed hardcoded "per hari" → dynamic `widget.pricingUnitName ?? 'unit'` in `customer_orders.dart`. Changed "Durasi Kerja (Hari)" → generic "Jumlah".
- **P1-3**: Added `uploadExtensionPaymentProof` endpoint (backend) + upload dialog with `ImagePicker` (Flutter). Customer can now self-service upload payment proof for extension.
- **P1-4**: Fixed `loginWithGoogle()` in `auth_provider.dart` to extract `verificationStatus` and `verificationNotes` from profile data.
- **P1-5**: Admin custom task endpoints were already wired in `admin.routes.ts`. No fix needed (false positive from audit).
- **P1-6**: Fixed `provider_welcome_screen.dart` — network failure now shows `setState(() => _checking = false)` instead of redirecting to shell.

### 2026-07-25 — P2 Complete (9/10, P2-3 deferred)

- **P2-1**: Replaced 76 hardcoded `Color(0xFF2563EB)` with `AppColors.primary` across 26 files. Added `app_colors.dart` import where missing.
- **P2-2**: Rewrote `customer_register_screen.dart` (115→210 lines) to match login screen quality: AppColors, logo, Form validation, password toggle, Google sign-up, "Sudah punya akun?" link, error container.
- **P2-3**: Deferred — requires Prisma migration (`notifications` table) + backend API + Flutter history page.
- **P2-4**: Added `'in_progress'` to `getTodayOrders` status filter in `orders.service.ts`.
- **P2-5**: Deleted dead `tracking_map_page.dart` (empty file, zero references).
- **P2-6**: Fixed rejection flow inconsistency — Google OAuth now allows rejected providers to log in (matching email/password behavior). Flutter handles rejection screen.
- **P2-7**: Added `registerProviderSchema` Zod schema with 23 field validations. Wired `validate(registerProviderSchema)` to `/register/provider` route.
- **P2-8**: Removed raw `verification_notes` leak from Google OAuth error message. Now uses same pattern as email/password login.
- **P2-9**: Fixed orange header `Colors.orange` → `AppColors.primary` in `customer_providers_by_category.dart`.
- **P2-10**: Created `GeocodingService` using Nominatim (OSM) for reverse geocoding. Custom task creation now uses human-readable address instead of raw lat/lng.

### 2026-07-25 — P3 Complete (13/15, 2 deferred)

- **P3-1**: Added `provider_schedules` cleanup in `custom-tasks.service.ts` when custom task completes — sets `is_booked: false`.
- **P3-2**: Deferred — needs review table + backend API + Flutter UI for custom task reviews.
- **P3-3**: Deferred — badge logic already works for key types; expansion is polish, not bug.
- **P3-4**: Schedule conflict already works bidirectionally via two-pronged check (orders + provider_schedules).
- **P3-5**: Added `withdrawTask()` method + `POST /:taskId/withdraw` route for provider to cancel after accepting a custom task. Cleans up order, payment, and schedule.
- **P3-6**: Added `allPricing` list to `ProviderModel` + `priceForUnit()` helper. Card display and navigation now use selected pricing unit's price.
- **P3-7**: Moved attachment count validation to before `tx.orders.create()` in `createOrder`.
- **P3-8**: Completion after 16:00 WITA now checks for active extensions — allowed if extension is pending/approved/waiting_payment/paid.
- **P3-9**: Extracted `PLATFORM_FEE = 2000` constant in backend. Added `ApiEndpoints.platformFee` in Flutter.
- **P3-10**: Removed all 26 `debugPrint()` calls from 9 files in production `lib/`.
- **P3-11**: Wrapped extension payment creation + status update in `prisma.$transaction`.
- **P3-12**: Wrapped non-accept transitions (rejected/completed/in_progress/etc.) in `prisma.$transaction` — order update + provider_profiles.total_jobs + provider_schedules cleanup are now atomic.
- **P3-13**: Added complete status labels (9 statuses) to `order_tracking_page.dart` — no more raw snake_case.
- **P3-14**: Provider app already has custom task detail via shared `TaskDetailPage(isProvider: true)` — no fix needed.
- **P3-15**: Deferred — notification tap routing already works for key types; expansion needs more FCM type coverage.
