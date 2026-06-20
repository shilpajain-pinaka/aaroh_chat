# aaroh_chat

[![pub.dev](https://img.shields.io/pub/v/aaroh_chat.svg)](https://pub.dev/packages/aaroh_chat)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A plug-and-play Flutter chat SDK — add a fully branded AI assistant to your app in **5 minutes**.

Built by **Aaroh AI** · *Powered by Aaroh* shown in every widget.

---

## Features

- 💬 **3-screen UI**: Chat · History · Language
- 🏢 **Company branding**: Your name + logo in the header
- 🧠 **Built-in engine**: Works offline, no API key needed
- 🤖 **Claude API support**: Plug in your Claude key for smarter responses
- 📚 **Knowledge base**: Feed company data — bot answers from it
- 🌐 **Multilingual**: English / Hindi / Hinglish
- 💾 **Chat history**: Auto-saved locally on device
- 🎙️ **Voice input**: Mic support built in
- ⚡ **Streaming**: Real-time token streaming for Claude

---

## Installation

```yaml
# pubspec.yaml
dependencies:
  aaroh_chat: ^1.0.0
```

```bash
flutter pub get
```

---

## Quick Start

### Option 1 — Full widget (new screen)

```dart
import 'package:aaroh_chat/aaroh_chat.dart';

// Inside your widget tree:
AarohChatWidget(
  config: AarohConfig(
    companyName: 'MyCompany',
  ),
)
```

### Option 2 — Navigate to chat

```dart
import 'package:aaroh_chat/aaroh_chat.dart';

ElevatedButton(
  onPressed: () => pushAarohChat(
    context,
    config: AarohConfig(companyName: 'MyCompany'),
  ),
  child: const Text('Open Chat'),
)
```

---

## AarohConfig Reference

| Parameter | Type | Description |
|-----------|------|-------------|
| `companyName` | `String` ✅ | Your company/product name (shown in header) |
| `companyLogoUrl` | `String?` | URL of your company logo |
| `claudeApiKey` | `String?` | Claude API key — enables AI mode |
| `knowledgeBase` | `List<Object>` (`String`/`KnowledgeItem`) | Company info, FAQs, product docs — see [Knowledge Base Format](#knowledge-base-format) |
| `searchEngineData` | `List<Object>` (`String`/`KnowledgeItem`) | Same format as `knowledgeBase`, separate list for your own organization |
| `knowledgeMatchThreshold` | `int` | Built-in engine: min keyword overlap to trigger a knowledge answer (default `1`) |
| `topics` | `List<TopicRule>` | Rule-based replies — "if user asks X, reply Y", with optional deep-link action. See [Topics & Rule-Based Replies](#topics--rule-based-replies) |
| `support` | `SupportConfig?` | Support email / Contact Us link / phone (phone shown only if asked). See [Support Fallback](#support-fallback) |
| `fallbackReply` | `String?` | Shown in built-in engine mode when nothing else matches |
| `botGreeting` | `String?` | Custom welcome message |
| `primaryColor` | `String?` | Brand color hex e.g. `'#E07A5F'` |
| `poweredByText` | `String` | Footer text (default: `'Powered by Aaroh'`) |

---

## Knowledge Base Format

`knowledgeBase` and `searchEngineData` both accept a `List` containing **either**:

- Plain `String`s — quick and simple
- `KnowledgeItem` objects — structured, with categories and keywords for better matching

You can mix both freely in the same list.

### Plain strings (simplest)

```dart
knowledgeBase: [
  'ShopMart sells electronics, clothing, and home goods.',
  'We offer free delivery on orders above ₹500.',
  'Return policy: 30-day hassle-free returns.',
],
```

### Structured `KnowledgeItem` (recommended for FAQs)

```dart
knowledgeBase: [
  KnowledgeItem(
    id: 'return-policy',          // optional, your own reference id
    question: 'What is your return policy?',
    answer: '30-day hassle-free returns, no questions asked.',
    category: 'Policies',         // optional, for your own organization
    keywords: ['refund', 'exchange', 'send back'], // optional, boosts matching
  ),
  KnowledgeItem(
    answer: 'ShopMart was founded in 2020 and ships across India.',
    // question/category/keywords are all optional — this is just a fact
  ),
],
```

| Field | Required | Purpose |
|-------|----------|---------|
| `id` | No | Stable reference if you update/remove entries later |
| `question` | No | The question this answers — omit for plain facts/docs |
| `answer` | **Yes** | The answer text or fact content |
| `category` | No | Grouping label, e.g. `'Pricing'`, `'Shipping'` |
| `keywords` | No | Extra search terms beyond what's in question/answer |

### How it's used in each mode

- **Claude API mode** — every entry (string or `KnowledgeItem`) is formatted and joined into Claude's system prompt automatically. Claude reasons over all of it.
- **Built-in engine mode** (no `claudeApiKey`) — each incoming message is keyword-matched against your knowledge base. If a confident match is found, the bot answers directly from that entry's `answer` instead of its generic wellness response. Tune sensitivity with `knowledgeMatchThreshold` (default `1` — at least one matching keyword).

```dart
AarohConfig(
  companyName: 'ShopMart',
  knowledgeBase: [ /* ... */ ],
  knowledgeMatchThreshold: 2, // require 2+ overlapping keywords to trigger
)
```

### Full example

```dart
AarohChatWidget(
  config: AarohConfig(
    companyName: 'ShopMart',
    claudeApiKey: 'sk-ant-YOUR_KEY', // omit to use built-in engine
    knowledgeBase: [
      'ShopMart sells electronics, clothing, and home goods.',
      KnowledgeItem(
        question: 'What is your return policy?',
        answer: '30-day hassle-free returns, no questions asked.',
        category: 'Policies',
        keywords: ['refund', 'exchange'],
      ),
      KnowledgeItem(
        question: 'Do you offer EMI?',
        answer: 'Yes, on orders above ₹2000 via major banks.',
        category: 'Payments',
      ),
    ],
    botGreeting: 'Hi! I\'m ShopMart\'s assistant. Ask me anything!',
  ),
)
```

---

## Topics & Rule-Based Replies

For general questions that aren't facts (e.g. "what's your pricing?", "track my order"), define `TopicRule`s — "if the user asks about X, reply with Y", with an optional deep link.

```dart
topics: [
  TopicRule(
    triggers: ['pricing', 'plans', 'cost', 'how much'],
    reply: 'Here are our current plans:',
    action: MessageAction(label: 'View Pricing', route: '/pricing'),
  ),
  TopicRule(
    triggers: ['track order', 'where is my order'],
    reply: 'Let me pull that up for you.',
    action: MessageAction(label: 'Track Order', actionId: 'track_order'),
  ),
],
```

`topics` is checked **first**, before the knowledge base — first matching rule wins.

### `MessageAction` — three ways to handle a tap

| Field | Use for |
|-------|---------|
| `route` | A named route in **your own app** (e.g. `/pricing`), pushed via `Navigator.pushNamed`. Works automatically with `pushAarohChat` (reuses your app's Navigator). With `AarohChatWidget`, pass your route table via its `routes` or `onGenerateRoute` param. |
| `url` | An external link (e.g. `https://yoursite.com/contact`), opened in the browser. |
| `actionId` | An arbitrary string passed to your own `onAction` callback — run any custom logic. |

You can set more than one — `onAction` fires first, then `route` is tried, falling back to `url` if `route` doesn't resolve.

```dart
pushAarohChat(
  context,
  config: myConfig,
  onAction: (actionId) {
    if (actionId == 'track_order') {
      // your own logic — open a bottom sheet, call an API, etc.
    }
  },
)
```

---

## Support Fallback

When a message looks support-related (e.g. "I need help", "this isn't working") and no `TopicRule` or knowledge entry matched, the bot uses `SupportConfig`:

```dart
support: SupportConfig(
  email: 'support@shopmart.com',        // shown by default
  contactUsUrl: 'https://shopmart.com/contact', // shown as a button if set
  phoneNumber: '1800-XXX-XXXX',         // shown ONLY if user explicitly asks for it
),
```

- **Email** is always shown for support-style queries.
- **Contact Us** link is shown as a tappable button if you set `contactUsUrl`.
- **Phone number** is *never* shown proactively — only when the user explicitly asks ("what's your number", "can I call you").

If nothing matches at all — not a topic, not knowledge, not a support query — `fallbackReply` is shown:

```dart
fallbackReply: "I'm not sure about that. Try asking about pricing, "
    "your order, or our return policy.",
```

If you don't set `fallbackReply`, a generic safe default is used instead.

---

## Claude API Setup

1. Get your key at [console.anthropic.com](https://console.anthropic.com)
2. Pass it as `claudeApiKey` in `AarohConfig`
3. Your `knowledgeBase` and `searchEngineData` are automatically injected into Claude's system prompt

**Model used:** `claude-sonnet-4-6`

---

## Screens

| Screen | How to access |
|--------|--------------|
| Chat | Main screen (default) |
| History | 🕐 icon in AppBar top-right |
| Language | 🌐 icon in AppBar top-right |

---

## Language Options

| Option | Code |
|--------|------|
| English | `LanguageTone.english` |
| Hindi | `LanguageTone.hindi` |
| Hinglish | `LanguageTone.hinglish` |

---

## Publishing to pub.dev

See [PUBLISHING.md](PUBLISHING.md) for step-by-step instructions.

---

## License

MIT © Aaroh AI
