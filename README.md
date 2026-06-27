# Tekken Cheat Sheet

A lightweight, polished Flutter application for Tekken 8 players to save, browse and manage key moves, punishes and combos per character. This project is designed for desktop and mobile and demonstrates a practical use of local SQLite storage, custom UI components, and developer utilities for exporting/importing database contents.

## Key Highlights
- Save and manage key moves, punishes and combo routes per character.
- Link combos with multiple launchers (one-to-many relationship).
- Modern, responsive UI with panels, animated controls and contextual tooltips.
- Developer utilities: export all tables to JSON and re-import default data for testing.

## Features
- Character library and detail view.
- Record and save moves with optional metadata: frames, on-hit, on-block, remark.
- Punish table with deduplication per frame value.
- Combo management with associated launchers.
- DB browser view to inspect records visually.
- One-click import of predefined default DB data (Helper().defaultDB).
- Export current DB state to JSON printable in console.

## Demonstration
Screenshots of key views (character list, move detail, punish table, combo management, DB browser) showcasing the UI and features can be found in the ".deliverables/screenshots/" folder.

You can also find a demo video here: [https://youtu.be/8CjFosyT-rE]

## Tech Stack
- Flutter (stable)
- Dart
- sqflite / sqflite_common_ffi (for desktop)
- SQLite (local storage)

## Prerequisites
- Flutter SDK (stable channel)
- For desktop testing: enable desktop support (Windows / macOS / Linux)
- Recommended editor: VS Code or Android Studio

## Quick Start

1. Clone the repo
   git clone <your-repo-url>

2. Install dependencies
   flutter pub get

3. Run (desktop)
   flutter run -d windows   # or -d macos / -d linux


You can also directly run the app in the "./deliverables/" folder and following the instructions in the README.md file there.


## Developer utilities (DB)
An helper methods exist in `DBProvider` to help with testing and fixtures:

- importDefaultDB()
  - Loads the hard-coded fixture from `Helper().defaultDB` and writes it into the database. Call `DBProvider.instance.importDefaultDB()` to populate the DB with default test data (optionally clears tables first).
Use these utilities for reproducible test data or CI fixtures.

## Project Structure (important files)
- lib/services/db_provider.dart — DB schema, CRUD and import/export helpers.
- lib/constants/helper.dart — fixtures and UI constants (including `defaultDB`).
- lib/views/ — UI screens (key moves, punishes, combos, DB browser, etc).
- lib/widgets/ — reusable UI components (panels, chips, input grid).
- assets/ — input icons and character portraits.

## What this project demonstrates
This section is targeted to quickly show the concrete technical skills and practices you can evaluate when reviewing the repository:

- Flutter & Dart proficiency
  - Modular widget architecture, custom widgets and responsive layouts.
  - Desktop & mobile support (usage of sqflite_common_ffi and platform-aware code).

- Local persistence & data modelling
  - Real-world SQLite schema design (one-to-many relations, foreign keys, ON DELETE CASCADE).
  - Transactional imports, export tooling and sequence handling for reproducible fixtures.

- UI / UX craftsmanship
  - Modern, themed UI (dark theme), animated controls and polished panels.
  - Attention to usability: tooltips, hover/focus states, cursor changes and keyboard focus.

- State management & async flows
  - Clear separation of DB service and UI logic; async handling for CRUD operations.
  - Defensive checks (existence of characters before inserts), conflict handling.

- Developer productivity & testing readiness
  - Export/import utilities for creating deterministic test data and CI fixtures.
  - Encapsulated helper (Helper().defaultDB) to seed known states quickly.

- Code quality & maintainability
  - Small focused methods, consistent naming and clear responsibilities across services and views.
  - Structured assets, constants and models to simplify extension.

- Attention to detail for production-quality apps
  - Error handling for DB operations, graceful UI fallbacks and accessibility considerations (focus/hover).
  - Use of transactions and foreign keys to ensure data consistency.

How to validate these skills quickly
- Run the app, open DB Browser view (using the HomeView button "Database" on the left side of the screen): inspect relationships (combos → launchers) and verify chips/launchers display.
- Inspect `lib/services/db_provider.dart` to see schema creation, FK handling and import logic.
- Review `lib/views/` and `lib/widgets/` to evaluate component design, responsive layout and animations.

## Contributing
- Open an issue for bugs or feature requests.
- Fork the repo, create a feature branch and send a PR with clear description and screenshots.
- Keep formatting consistent (dartfmt) and provide unit/UI tests where relevant.

## Contact
Erwan Rossignol — erwan@hotmail.ch  
Project repository: https://github.com/E-Rossignol/tekken8_cheat_sheet.git
