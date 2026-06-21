# Publishing to pub.dev — Step by Step Guide

## Prerequisites

1. **Flutter SDK** installed (>=3.10.0)
2. **Google account** (pub.dev uses Google login)
3. **pub.dev account** — go to [pub.dev](https://pub.dev) and log in with Google

---

## Step 1 — Prepare your package

### Required files checklist:
```
aaroh_chat/
├── lib/
│   └── aaroh_chat.dart        ✅ Main export file
├── pubspec.yaml               ✅ Package info
├── README.md                  ✅ Documentation
├── CHANGELOG.md               ✅ Version history (required!)
├── LICENSE                    ✅ MIT license (required!)
└── example/
    └── lib/
        └── main.dart          ✅ Example app (bonus points)
```

---

## Step 2 — Set up pubspec.yaml correctly

```yaml
name: aaroh_chat          # this is the name shown on pub.dev
description: >            # 60-180 characters
  A plug-and-play Flutter chat SDK...
version: 1.0.0            # Semantic versioning
homepage: https://github.com/yourname/aaroh_chat
repository: https://github.com/yourname/aaroh_chat
```

**Important:** `name` must be globally unique on pub.dev.
Check first: `https://pub.dev/packages/aaroh_chat`

---

## Step 3 — Create CHANGELOG.md

```markdown
## 1.0.0

* Initial release
* Chat, History, Language screens
* Built-in Aaroh engine + Claude API support
* Company branding support
* Knowledge base injection
```

---

## Step 4 — Create a LICENSE file

```
MIT License

Copyright (c) 2025 Aaroh AI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

---

## Step 5 — Dry run (test first, don't publish yet)

```bash
cd aaroh_chat/
flutter pub publish --dry-run
```

This will show errors without actually publishing.

**Common errors and fixes:**

| Error | Fix |
|-------|-----|
| `description too short` | Make pubspec description 60+ characters |
| `No LICENSE file` | Add a LICENSE file |
| `Missing example` | Create example/lib/main.dart |
| `Import not found` | Check all your imports |
| `score too low` | Add README + example + dartdoc comments |

---

## Step 6 — Improve your score (pub.dev score matters!)

```bash
# Run the analysis tool
dart pub publish --dry-run
dart analyze
```

**To boost your score:**
- ✅ `dart analyze` with zero warnings/errors
- ✅ Dartdoc comments (`///` comments) on public APIs
- ✅ README.md with examples
- ✅ CHANGELOG.md
- ✅ LICENSE file
- ✅ example/ folder
- ✅ 80%+ code coverage (optional but good)

---

## Step 7 — Actually publish

```bash
flutter pub publish
```

You'll see this in the terminal:
```
Pub needs your authorization to upload packages on your behalf.
... (a browser will open for Google login)
```

Log in with your Google account → Allow → Done!

---

## Step 8 — Verify

After a few minutes, check:
```
https://pub.dev/packages/aaroh_chat
```

Your package will appear there.

---

## To publish a new version

```yaml
# update version in pubspec.yaml
version: 1.0.1
```

```markdown
# add an entry in CHANGELOG.md
## 1.0.1
* Bug fix: Claude streaming improved
* Added custom primaryColor support
```

```bash
flutter pub publish
```

---

## Tips for a High Pub Score (target: 100/140)

1. **Dartdoc comments** on every public class/method:
   ```dart
   /// Creates an Aaroh chat widget.
   /// 
   /// [config] contains company branding and AI settings.
   class AarohChatWidget extends StatefulWidget {
   ```

2. **Complete example app** (example/lib/main.dart)

3. **Run dart format:**
   ```bash
   dart format lib/
   ```

4. **dart analyze with zero issues:**
   ```bash
   dart analyze lib/
   ```

5. **Add topics** in pubspec.yaml:
   ```yaml
   topics:
     - chat
     - ai
     - chatbot
     - sdk
     - flutter
   ```

---

## Also put it on GitHub (recommended)

1. Create a GitHub repo: `aaroh_chat`
2. Push your code
3. Set the `repository:` URL in pubspec.yaml
4. pub.dev automatically shows GitHub stats

---

## Troubleshooting

**"Package name already taken"**
→ Try `aaroh_chat_sdk` or `aaroh_flutter_chat`

**"Too many publish attempts"**
→ pub.dev has rate limits — try again after 1 hour

**"Authentication failed"**
→ Run `dart pub logout` then `dart pub publish` again

**Score is below 40**
→ Check README, LICENSE, CHANGELOG, example — all of them
→ Run `dart analyze` — fix any warnings

**"Package upload canceled" right after confirming with `y`**
→ This usually points to an authentication problem rather than a validation problem (validation already passed if you got to the confirmation prompt). Try:
```bash
dart pub login
```
Run this on its own first to confirm you're properly authenticated and to re-trigger the browser OAuth flow if needed. Then retry with verbose output to see the actual server response:
```bash
flutter pub publish -v
```