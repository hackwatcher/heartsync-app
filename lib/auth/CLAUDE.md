# Auth Domain - CLAUDE.md

## Responsibility
Handles user authentication, profile management, and the "Partner Linking" process.

## Key Components
- `auth_repository.dart`: Interface for login/logout.
- `partner_service.dart`: Logic for connecting two accounts.
- `user_model.dart`: Data structure for the user.

## Guidelines
- Use Secure Storage for tokens.
- Never log passwords or sensitive PII.
- Follow the "Link via QR/Code" pattern for partner connection.
