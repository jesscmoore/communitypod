# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

CommunityPod is a Flutter app (forked from NotePod) for privacy-preserving news sharing using [Solid Pods](https://solidproject.org/about) — decentralized personal data vaults. News are stored as encrypted RDF/Turtle files on the user's own Solid Pod server.

## Common Commands

```bash
flutter pub get              # Install dependencies
flutter run -d chrome        # Run on Chrome (web)
flutter run -d macos         # Run on macOS desktop
flutter analyze --fatal-infos  # Static analysis (CI enforced)
dart format .                # Format code (CI enforced)
```

### macOS/iOS — extra setup required

The `ios/` and `macos/` folders use `project.yml` (XcodeGen) instead of raw Xcode files. After any build config change:

```bash
bash update_project.sh [macos/ios]   # Regenerates Xcode config + pod install
flutter run [--debug -d macos]
```

### Integration tests

Do **not** use `flutter test integration_test/` — it fails on desktop due to Flutter limitations and is banned in CI. Use `make qtest` instead (runs tests individually).

## CI Lint Checks

All of these must pass before merging (run against Flutter 3.41.4):

| Check | Command |
|---|---|
| Static analysis | `flutter analyze --fatal-infos` |
| Formatting | `dart format --set-exit-if-changed .` |
| Unused code | `metrics check-unused-code --disable-sunset-warning lib` |
| Unused files | `metrics check-unused-files --disable-sunset-warning lib` |
| Import order | `import_order --check` |
| Line length | `make locmax` |
| Copyright headers | All non-generated `.dart` files must contain `Copyright` |
| Markdown lint | `markdownlint *.md lib assets installers` |

## Code Requirements

- **Copyright header**: Every `lib/*.dart` file must have a copyright header. Generated files (`*.g.dart`, `*.freezed.dart`, etc.) are excluded.
- **Single quotes**: Use `prefer_single_quotes` (enforced by linter).
- **Trailing commas**: Required (`require_trailing_commas`).
- **No `print()`**: Use proper logging (`avoid_print` rule).
- **Import order**: Enforced by `import_order_lint`.

## Architecture

### Data flow

```
Solid Pod (encrypted Turtle files on remote server)
  → rest_api.dart: readPod() / getOwnNewsList()
  → NewsFileHelper.scanFileListDirectory() — scans Pod directory
  → TurtleSerializer.newsFromTurtle() — parses TTL to NewsContent
  → Encryption.decryptVal() — on-device decryption
  → Note / OwnNews models
  → FutureBuilder renders UI
```

### State management

No external state container (no Provider/Riverpod/BLoC). The app uses:
- **`FutureBuilder`** for async data fetching (primary pattern)
- **`StatefulWidget`** for local form/UI state
- **`flutter_form_builder`** for edit forms (`GlobalKey<FormBuilderState>`)

### Key directories

- `lib/common/rest_api/` — Pod API layer (`rest_api.dart`, `file_helper.dart`, `operations.dart`)
- `lib/models/` — Data models (`News`, `OwnNews`, `NewsContent`, `NewsCallResult`)
- `lib/news/` — Feature screens (list, view, edit, new, share news)
- `lib/utils/turtle/` — RDF Turtle serialization (`note_serializer.dart`, `parsing_utils.dart`)
- `lib/utils/encryption.dart` — On-device encrypt/decrypt (server never sees plaintext)
- `lib/utils/upload_image.dart` — Upload images to Pod with encryption
- `lib/widgets/` — Reusable UI components
- `lib/constants/` — App-wide constants including RDF predicate names (`turtle_structures.dart`)

### Data storage format

News are stored as RDF Turtle (`.ttl`) files on the user's Solid Pod. `TurtleSerializer` converts between TTL strings and `NewsContent` objects using the `rdflib` package. Predicate names are defined in `lib/constants/turtle_structures.dart`.

### Authentication

Solid OIDC flow via `solidui`'s `SolidLogin` widget — authentication happens through an external browser identity provider, not within the app. The `solidpod` package handles all Pod interactions.

### Responsive layout

Desktop (≥960px): sidebar menu + content. Mobile: tab-based navigation. Handled in `lib/common/responsive.dart`.

## Key Dependencies

- **solidpod** / **solidui** — Solid Pod operations and UI scaffolding
- **solid_encrypt** — On-device encryption
- **rdflib** — RDF/Turtle parsing and generation
- **flutter_form_builder** + **form_builder_validators** — Form management
- **markdown_widget** + **markdown_toolbar** — Markdown editor/renderer
- **file_picker** — File/image selection

<!-- markdownlint-disable-file  MD009 MD012 MD013 MD029 MD032 MD036 MD040 MD060 -->
<!-- MD009 - no trailing spaces -->
<!-- MD012 - no multiple blanks -->
<!-- MD013 - line limit -->
<!-- MD036 - emphasised text as heading -->
