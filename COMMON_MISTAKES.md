# COMMON_MISTAKES.md - HeartSync

## Flutter & Architecture
- **Avoid Massive Widgets**: Don't put business logic inside the `build` method.
- **Hardcoded Strings**: Always use a localization system or at least a constants file.
- **Direct Domain Imports**: Never import `lib/auth/...` from `lib/stats/...`. Use interfaces or shared models.
- **Context Leaks**: Be careful with using `BuildContext` across async gaps.
- **State Over-usage**: Don't use heavy state management for simple local UI toggles.

## Design & UI
- **Ad-hoc Colors**: Never use `Colors.red`. Always use `Theme.of(context).colorScheme...`.
- **Inconsistent Padding**: Use `DesignTokens` or standard spacing units (8, 16, 24).
- **Missing Loading States**: Every async action must have a loading/error state.

## HeartSync Specific
- **Sync Lag**: Forgetting to handle offline states or slow network in real-time features.
- **Privacy**: Logging sensitive partner data. Ensure encryption for all communication.
- **Battery Drain**: Frequent polling for sync. Use WebSockets or Push Notifications.
