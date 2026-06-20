# pub.dev pe Publish Kaise Karein — Step by Step Guide

## Prerequisites

1. **Flutter SDK** installed (>=3.10.0)
2. **Google account** (pub.dev uses Google login)
3. **pub.dev account** — [pub.dev](https://pub.dev) pe jaake Google se login karo

---

## Step 1 — Package taiyaar karo

### Zaroori files checklist:
```
aaroh_chat/
├── lib/
│   └── aaroh_chat.dart        ✅ Main export file
├── pubspec.yaml               ✅ Package info
├── README.md                  ✅ Documentation
├── CHANGELOG.md               ✅ Version history (zaroori!)
├── LICENSE                    ✅ MIT license (zaroori!)
└── example/
    └── lib/
        └── main.dart          ✅ Example app (bonus points)
```

---

## Step 2 — pubspec.yaml sahi karo

```yaml
name: aaroh_chat          # pub.dev pe yahi naam dikhega
description: >            # 60-180 characters
  A plug-and-play Flutter chat SDK...
version: 1.0.0            # Semantic versioning
homepage: https://github.com/yourname/aaroh_chat
repository: https://github.com/yourname/aaroh_chat
```

**Important:** `name` globally unique hona chahiye pub.dev pe.
Pehle check karo: `https://pub.dev/packages/aaroh_chat`

---

## Step 3 — CHANGELOG.md banao

```markdown
## 1.0.0

* Initial release
* Chat, History, Language screens
* Built-in Aaroh engine + Claude API support
* Company branding support
* Knowledge base injection
```

---

## Step 4 — LICENSE file banao

```
MIT License

Copyright (c) 2025 Aaroh AI

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software...
```

---

## Step 5 — Dry run (pehle test karo, publish mat karo)

```bash
cd aaroh_chat/
flutter pub publish --dry-run
```

Yeh errors dikhayega bina actually publish kiye.

**Common errors aur fixes:**

| Error | Fix |
|-------|-----|
| `description too short` | pubspec description 60+ chars karo |
| `No LICENSE file` | LICENSE file add karo |
| `Missing example` | example/lib/main.dart banao |
| `Import not found` | Sab imports check karo |
| `score too low` | README + example + dartdoc comments add karo |

---

## Step 6 — Score badhao (pub.dev score important hai!)

```bash
# Analysis tool run karo
dart pub publish --dry-run
dart analyze
```

**Score ke liye:**
- ✅ `dart analyze` zero warnings/errors
- ✅ Dartdoc comments (/// comments) on public APIs
- ✅ README.md with examples
- ✅ CHANGELOG.md
- ✅ LICENSE file
- ✅ example/ folder
- ✅ 80%+ code coverage (optional but good)

---

## Step 7 — Actually publish karo

```bash
flutter pub publish
```

Terminal mein yeh aayega:
```
Pub needs your authorization to upload packages on your behalf.
... (browser khulega Google login ke liye)
```

Google account se login karo → Allow karo → Done!

---

## Step 8 — Verify karo

Kuch minutes baad:
```
https://pub.dev/packages/aaroh_chat
```

pe package dikhega.

---

## Nayi version update karne ke liye

```yaml
# pubspec.yaml mein version update karo
version: 1.0.1
```

```markdown
# CHANGELOG.md mein entry add karo
## 1.0.1
* Bug fix: Claude streaming improved
* Added custom primaryColor support
```

```bash
flutter pub publish
```

---

## Tips for High Pub Score (100/140 target)

1. **Dartdoc comments** har public class/method pe:
   ```dart
   /// Creates an Aaroh chat widget.
   /// 
   /// [config] contains company branding and AI settings.
   class AarohChatWidget extends StatefulWidget {
   ```

2. **Example app** complete banao (example/lib/main.dart)

3. **dart format** run karo:
   ```bash
   dart format lib/
   ```

4. **dart analyze** zero issues:
   ```bash
   dart analyze lib/
   ```

5. **Topics** add karo pubspec.yaml mein:
   ```yaml
   topics:
     - chat
     - ai
     - chatbot
     - sdk
     - flutter
   ```

---

## GitHub pe bhi daalo (recommended)

1. GitHub pe repo banao: `aaroh_chat`
2. Code push karo
3. pubspec.yaml mein `repository:` URL set karo
4. pub.dev automatically GitHub stats show karta hai

---

## Troubleshooting

**"Package name already taken"**
→ `aaroh_chat_sdk` ya `aaroh_flutter_chat` try karo

**"Too many publish attempts"**
→ pub.dev limits hai, 1 ghante baad try karo

**"Authentication failed"**
→ `dart pub logout` then `dart pub publish` again

**Score 40 se kam hai**
→ README, LICENSE, CHANGELOG, example — sab check karo
→ `dart analyze` run karo — warnings fix karo
