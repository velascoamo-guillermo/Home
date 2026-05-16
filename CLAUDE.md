# Home — Project Guidelines

## Swift 6 Strict Concurrency

**This project targets Swift 6 with full strict concurrency. Never regress to Swift 5.**

Current settings (enforced in `Home.xcodeproj`):

| Setting | Value |
|---|---|
| `SWIFT_VERSION` | `6.0` |
| `SWIFT_DEFAULT_ACTOR_ISOLATION` | `MainActor` |

### Rules

- All new code must compile clean — zero concurrency errors, zero data-race warnings.
- `@MainActor` is the default isolation for every type. Only mark `nonisolated` or `actor` when there is a clear reason.
- Never use `@unchecked Sendable`, `nonisolated(unsafe)`, or `@preconcurrency` without a documented safety invariant in the same file. Treat these as tech debt; remove them in the same PR or file a TODO with a ticket.
- Prefer `async/await` over `DispatchQueue`, `OperationQueue`, or `Timer` for new code.
- Network calls and file I/O in `ExtractionService` and `DataStore` run on the cooperative thread pool. They must not block the main actor.
- `Task { }` inherits caller isolation (`@MainActor` by default). Use `Task { @concurrent in ... }` + `await MainActor.run { }` when the synchronous prefix does not need the main actor.
- No `Task.detached` without a written reason.

### When adding or reviewing code

1. Run `Cmd+B` — build must succeed with zero errors.
2. Check for new concurrency warnings — fix before committing.
3. Run `Cmd+U` — all tests must pass.

### Migration debt

The following escape hatches are forbidden in new code and must be removed if found during reviews:

- `DispatchQueue.main.async` → replace with `await MainActor.run { }` or `@MainActor func`
- `DispatchQueue.global().async` → replace with `Task { @concurrent in ... }`
- Bare `Thread` APIs

---

## Architecture

- **Persistence**: `DataStore` (`@Observable`) holds all app data as `AppData` (Codable JSON) + binary files in `Documents/PetFiles/`.
- **Environment injection**: `DataStore` and `AuthManager` injected via `.environment()` from `ContentView`.
- **No third-party dependencies** — UIKit bridges, system frameworks only.
- **Keychain**: API keys stored via `KeychainService` (Security framework). Never hardcode secrets.

## Code style

- No comments unless the WHY is non-obvious.
- No `@discardableResult` on new functions except where the caller pattern clearly warrants it.
- Each Swift file has one primary type.
- Accessibility: all icon-only buttons need a label or `.accessibilityLabel`. Decorative images need `.accessibilityHidden(true)`.
