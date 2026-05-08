# Sync Domain - CLAUDE.md

## Responsibility
Manages real-time heartbeats, presence, and shared state synchronization between partners.

## Key Components
- `sync_engine.dart`: The core WebSocket or Stream-based sync logic.
- `heartbeat_monitor.dart`: Detects if the partner is online/active.
- `sync_state.dart`: Immutable state representing the "Sync" status.

## Guidelines
- Optimize for low latency.
- Handle "Reconnecting" states gracefully in the UI.
- Use `compute()` for heavy state diffing if necessary.
