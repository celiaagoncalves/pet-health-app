# 🗺 Roadmap

Where Pet Health has been, where it's going, and what's parked in the backlog. For technical context see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

> Last updated: 2026-05-13

---

## ✅ Shipped

### Foundation
- Cross-platform Flutter scaffolding (iOS + Android)
- Hive persistence with hand-written `TypeAdapter`s
- `flutter_local_notifications` scheduling (3 days before + day-of, at 09:00 local)
- `LocaleService` runtime language switching, persisted in `shared_preferences`
- Material 3 + light/dark theme following system

### Localization
- 🇵🇹 **Portuguese** (default) + 🇬🇧 **English**, switchable from Settings
- All UI, notifications, enum labels and dates pass through `AppLocalizations`

### Pet management (Phase 1)
- **8 species** + custom (`Outro`): dog, cat, bird, rabbit, hamster, fish, reptile, other
- Custom species name when picking "Other"
- **Status**: alive / deceased (with death date) / archived. Archived & deceased hidden by default, toggleable
- **Caderneta** sections in the pet form & detail:
  - Identification: microchip, insurance company, insurance policy
  - Veterinarian: name, phone
  - Health: weight (kg), sterilized toggle, allergies, medical conditions
- **Age calculation** with day granularity (`5 dias`, `1 mês`, `2 anos`); default birth date is today
- Dynamic species grouping in the pet list (only shows sections that have pets)

### Health records
- 6 record types (vaccine, deworming, consultation, surgery, exam, other) with icons and accent colors
- Optional `nextDueDate` to drive notifications
- Filter timeline by record type
- Per-pet stats: vaccines · deworming · pending alerts
- Cross-pet alerts view, grouped by **Overdue** / **Upcoming**

---

## 🔨 In progress

_None._ Phase 1 just landed. Pick the next phase below to start.

---

## 📋 Next up — planned phases

Each phase is a self-contained block of work: compiles, ships to the emulator, gets tested.

### Phase 2 — Photos

> **Goal:** put a face to each pet.

- Pet **profile photo** (single image, replaces the species emoji avatar)
- **Photo diary** — chronological list of photos with optional captions and dates
- Photos stored in the app's documents directory (`path_provider`), referenced by path in Hive
- Use [`image_picker`](https://pub.dev/packages/image_picker) for camera + gallery
- iOS permissions: `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription`
- Android permissions: handled by image_picker automatically
- Schema bump: add `photoPath: String?` to `Pet`, new `PhotoEntry` model (`id`, `petId`, `path`, `caption`, `date`)

### Phase 3 — Notes / journal

> **Goal:** capture daily behavioral observations.

- Free-text **notes** attached to a pet, ordered chronologically (newest first)
- Optional tag/category (e.g. "feeding", "training", "mood")
- Notes screen accessible from pet detail
- New `Note` model (typeId **3**): `id`, `petId`, `content`, `category`, `createdAt`

### Phase 4 — Calendar

> **Goal:** see everything date-related at a glance.

- Monthly calendar view (new top-level tab or screen accessed from Alerts)
- Dots/badges on dates that have events:
  - 🎂 Pet birthdays (recurring annually)
  - 💉 Scheduled vaccinations / deworming
  - 📅 Health record alerts (`nextDueDate`)
- Tap a date to see the day's events
- Use [`table_calendar`](https://pub.dev/packages/table_calendar)

### Phase 5 — Breed autocomplete

> **Goal:** stop forcing free-text into a finite set of values.

- Type-ahead suggestions in the breed field, filtered as you type
- Curated local JSON: ~150 dog breeds + ~50 cat breeds + smaller lists for other species
- Both PT and EN names indexed
- Falls back to free text if breed isn't in the list (no hard validation)

---

## 🔭 Backlog — not committed

| Idea | Notes |
|---|---|
| **Weight history** | Track weight over time, show as line chart |
| **PDF export of clinical history** | One PDF per pet for vet visits — `pdf` + `printing` packages |
| **iCloud / Firebase backup** | Currently 100% local; backup is the #1 risk if user changes phone |
| **Apple Watch / Wear OS companion** | Glanceable next-due reminders |
| **Adaptive UI** | Cupertino on iOS, Material on Android — only worth doing once there's a real iOS user base |
| **More languages** | Spanish, French — clone `app_pt.arb`, translate, register in `LocaleService.supported` |
| **Tests** | Widget tests for the main flows + integration test on emulator |
| **CI** | GitHub Actions for Android build + lint; macOS runner for iOS when we get there |
| **App icon (real PNG)** | [assets/logo.svg](assets/logo.svg) exists — needs conversion to PNG + `flutter_launcher_icons` config |
| **Real migration strategy** | Drop the schema-wipe in `DatabaseService.init()` once there are real users |

---

## 🐛 Known issues / debt

| Issue | Severity | Notes |
|---|---|---|
| Hive boxes wiped on schema bump | High before release | Acceptable now, blocker before any real user touches the app |
| `platform-tools.backup` warning during Android build | Cosmetic | Dev-machine specific; delete `%LOCALAPPDATA%\Android\Sdk\platform-tools.backup` to silence |
| No widget tests | Medium | Default `test/widget_test.dart` was deleted; no replacement yet |
| Notification IDs derived from `hashCode` | Low | Vanishingly small collision risk — would only matter at huge scale |

---

## How to propose changes

Open an issue or PR. The repo follows the conventions in [CLAUDE.md](CLAUDE.md) — most importantly: **no hardcoded user strings**, **stay in Dart**, **no `build_runner`**.
