# Contributing to any_image

Thank you for your interest in contributing to `any_image`. This document outlines the process and expectations for contributing to this project.

---

## Scope

`any_image` is currently accepting contributions in the following areas:

- **Bug fixes** — incorrect rendering behaviour, resolver edge cases, platform-specific issues
- **Improvements** — performance, code quality, documentation, test coverage

New feature proposals are evaluated on a case-by-case basis as the project matures. If you have a feature idea, open a Discussion before writing any code. This avoids wasted effort if the proposal does not align with the project direction.

---

## Before You Start

- Search [existing issues](https://github.com/Sameer330/any_image/issues) before opening a new one
- For bug fixes, open an issue first and describe the problem clearly
- For improvements, open an issue to discuss the change before submitting a PR
- Do not open a pull request without a corresponding issue unless it is a trivial fix (typo, doc correction)

---

## Development Setup

**Requirements:**
- Flutter SDK `>=3.0.0`
- Dart SDK `>=3.0.0`

**Clone and setup:**

```bash
git clone https://github.com/Sameer330/any_image.git
cd any_image
flutter pub get
```

**Run tests:**

```bash
flutter test
```

**Run the example app:**

```bash
cd example
flutter pub get
flutter run
```

---

## Architecture

`any_image` is structured around two core extension points:

- **`SourceResolver`** — classifies an opaque source string into a location and format
- **`ImageRenderer`** — renders a `ResolvedSource` into a Flutter widget

If your contribution touches resolution logic, add or update tests in `test/resolver/`. If it touches rendering, ensure the widget layer still composes correctly.

Refer to `DESIGN.md` for a full architectural overview before making structural changes.

---

## Code Standards

All contributions must pass the following checks before a PR will be reviewed:

**Formatting:**
```bash
dart format --set-exit-if-changed .
```

**Analysis:**
```bash
flutter analyze
```

**Tests:**
```bash
flutter test
```

All three must pass with zero errors and zero warnings. PRs that fail any of these checks will not be reviewed until they are fixed.

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

| Prefix | Use for |
|--------|---------|
| `feat:` | A new capability |
| `fix:` | A bug fix |
| `docs:` | Documentation only |
| `test:` | Adding or updating tests |
| `refactor:` | Code change that is not a fix or feature |
| `chore:` | Build process, tooling, dependencies |

Examples:
```
fix: handle SVG resolution for asset paths with query params
docs: update README with format override example
test: add pipeline tests for no-extension network URLs
```

---

## Pull Request Process

1. Fork the repository and create a branch from `master`
2. Branch naming: `fix/short-description` or `improvement/short-description`
3. Make your changes and ensure all checks pass
4. Fill out the pull request template completely
5. Link the PR to the relevant issue using `Closes #issue_number`
6. Request a review — do not merge your own PR

PRs that do not follow this process will be closed without review.

---

## Reporting Bugs

Use the [bug report template](https://github.com/Sameer330/any_image/issues/new?template=bug_report.md) and include:

- Flutter and Dart SDK versions
- The source string that caused the issue
- Expected behaviour vs actual behaviour
- A minimal reproducible example if possible

---

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

---

## License

By contributing to `any_image`, you agree that your contributions will be licensed under the [MIT License](LICENSE).