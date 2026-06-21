## 1.2.1+1

### Bug Fixes
* Fixed issues with message action handling in certain navigation scenarios
* Fixed knowledge base matching edge cases causing incorrect fallback responses
* Fixed support message detection inconsistencies in the built-in engine
* Fixed route navigation issues when using nested navigators
* Fixed chat history synchronization issues in specific cases
* Fixed minor UI rendering and layout inconsistencies
* Fixed various null-safety and stability issues
* General bug fixes and performance improvements

## 1.2.1

* Upgraded Flutter and package dependencies to the latest stable versions for improved compatibility and performance
* Added support for the latest Flutter SDK releases
* Improved compatibility with newer Android and iOS platform versions
* Enhanced deep-link navigation handling and route resolution stability
* Improved built-in engine response matching performance
* Updated internal dependencies and build configurations
* Improved overall SDK reliability and startup performance

## 1.2.0

* Added `TopicRule` — define "if user asks about X, reply with Y" rules for the built-in engine, checked before the knowledge base
* Added `MessageAction` on bot replies — tappable buttons supporting named routes (`route`), external URLs (`url`), and custom callbacks (`actionId`)
* Added `onAction` callback on `AarohChatWidget` and `pushAarohChat` for handling custom action taps
* Added `routes` / `onGenerateRoute` params on `AarohChatWidget` so deep-link routes resolve inside its own navigator
* Added `SupportConfig` — support email shown by default for support-style messages, optional "Contact Us" link, phone number shown only when explicitly requested
* Added `AarohConfig.fallbackReply` — custom message shown when nothing else matches in built-in engine mode
* **Fix:** built-in engine no longer falls through to the generic wellness engine for unmatched general questions — it now uses topics → knowledge base → support detection → fallback reply → safe generic default, in that order

## 1.1.0

* Added `KnowledgeItem` model — structured knowledge entries with `question`, `answer`, `category`, `keywords`
* `knowledgeBase` / `searchEngineData` now accept `String` and `KnowledgeItem` mixed in the same list (fully backward compatible)
* **Fix:** built-in Aaroh engine now actually uses the knowledge base — previously it was only wired into Claude API mode. Messages are now keyword-matched against your knowledge base; confident matches are answered directly
* Added `AarohConfig.knowledgeMatchThreshold` to tune built-in engine matching sensitivity

## 1.0.0

* Initial release of `aaroh_chat` Flutter SDK
* Chat screen with company branding (name + logo)
* History screen accessible via top AppBar icon
* Language selection screen (English / Hindi / Hinglish)
* Built-in Aaroh NLP engine — works offline, no API key needed
* Claude API integration — pass your key for AI-powered responses
* Knowledge base injection — company data fed to Claude system prompt
* Search engine data support for custom Q&A pairs
* Real-time streaming responses (Claude mode)
* Local chat history with session management
* Voice input (speech-to-text) support
* "Powered by Aaroh" footer branding
* Crisis detection with helpline banner
