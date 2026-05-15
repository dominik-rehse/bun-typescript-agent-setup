---
description: Use when creating new modules, files, or structuring the project.
alwaysApply: false
globs: "**/*"
---

# Project structure

## Feature-based organization
- Group files by feature or domain (e.g., `src/users/`, `src/products/`) rather than by technical role (e.g., `src/controllers/`, `src/models/`).
- Each feature directory should contain its own logic, models, and tests.
- Keep a flat structure where possible; avoid deep nesting unless the feature is exceptionally complex.
- Use `src/index.ts` or `src/main.ts` as the main entry point that wires features together.
