# HeartSync - Root CLAUDE.md

This is the central entry point for the HeartSync project. This project follows a Domain-Driven structure.

## Quick Commands
```bash
flutter run           # Run on default device
flutter analyze       # Check for linting issues
flutter test          # Run tests
```

## Design System (Soft Gravity)
- **Background**: `#1A0A10` (Deep Rose-Black)
- **Typography**: 
    - *Display*: `Cormorant Garamond` (Italic)
    - *Headings*: `Syne` (Weight 700)
    - *UI/Body*: `DM Sans` (Weight 300–500 only)
- **Accents**: Coral `#FF6B6B` + Violet `#C084FC`
- **Surfaces**: Frosted glass (`rgba(255,255,255,0.04)` + `backdrop-filter: blur(12px)`)
- **Motion**: `cubic-bezier(0.34,1.56,0.64,1)` duration `400–600ms` (Spring animations)
- **Constraints**: Dark theme only, 390px mobile target.

## Domain Router
Refer to specific domain guidance for detailed instructions:

| Domain | Path | Responsibility |
|---|---|---|
| **Auth** | `lib/auth/CLAUDE.md` | User identity, login, partner connection. |
| **Sync** | `lib/sync/CLAUDE.md` | Real-time state synchronization & heartbeats. |
| **Chat** | `lib/chat/CLAUDE.md` | Message exchange and shared emotions. |
| **Stats** | `lib/stats/CLAUDE.md` | Relationship analytics & insights. |
| **UI** | `lib/ui/CLAUDE.md` | Design system, themes, and shared widgets. |

## Project Documentation
- [Architecture Map](./ARCHITECTURE_MAP.md)
- [Common Mistakes](./COMMON_MISTAKES.md)

## Development Principles
1. **Domain Isolation**: Keep logic within its domain.
2. **UI Consistency**: Use `lib/ui/` for all styling.
3. **Reactive First**: Use streams and observers for real-time data.
