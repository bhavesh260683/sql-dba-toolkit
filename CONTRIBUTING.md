# Contributing

Contributions should remain safe, focused, and easy to review.

## Script standards

- Use a descriptive numbered filename.
- Include purpose, compatibility, permissions, and safety notes in the header.
- Prefer read-only diagnostics. Put state-changing utilities in a clearly separated folder.
- Avoid `SELECT *`; name output columns explicitly.
- Use `TRY_CONVERT`, `NULLIF`, and appropriate numeric types where arithmetic may fail.
- Explain whether values are cumulative, point-in-time, or database-scoped.
- Never include server names, credentials, client names, or production data.

## Validation

Test scripts on supported SQL Server versions when possible. In a pull request, state the editions and versions tested and include sanitized sample output for major additions.
