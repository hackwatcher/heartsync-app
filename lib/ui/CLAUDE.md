# UI Domain - CLAUDE.md

## Responsibility
Shared design system, themes, and atomic UI components.

## Design Tokens
- **Background**: Deep rose-black (`#0D0208` or similar deep rose tinted black).
- **Typography**: 
    - Display: `GoogleFonts.cormorantGaramond()`
    - UI/Body: `GoogleFonts.dmSans()`
- **Accents**: Coral (`#FF7F50`) to Violet (`#8A2BE2`) gradients.
- **Effects**: Glassmorphism (Frosted glass) using `BackdropFilter` with `ImageFilter.blur`.

## Key Components
- `sync_theme.dart`: The primary theme definition incorporating the above tokens.
- `sync_colors.dart`: Standardized palette (Heart Red, Deep Rose, Coral, Violet).
- `sync_widgets/`: Components implementing the frosted glass effect.

## Guidelines
- Follow the "Rose Gold & Dark" aesthetic from wanalysis if applicable, or define new premium styles.
- Use `SizedBox` for spacing, never hardcoded margins.
- Ensure all widgets are responsive.
