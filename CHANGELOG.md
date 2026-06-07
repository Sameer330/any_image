# Changelog

All notable changes to `any_image` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.0.2] - 2026-06-07

### Added

- `AsyncSourceResolver` — interface for resolvers requiring async operations
- `MagicBytesResolver` — detects image format from binary magic bytes via HTTP range request (`bytes=0-63`); supports PNG, JPEG, WebP, GIF, SVG
- `allowMagicBytes` param on `AnyImage` — opt out of async format detection
- `DESIGN.md` — architectural overview for contributors

### Changed

- `ResolverPipeline` — extended with async resolver support; async pass only runs when format is unresolved after sync pass
- `AnyImage` widget — manages `http.Client` lifecycle for async resolution

## [0.0.1] - 2026-04-22

### Added

- `AnyImage` widget — universal image widget that accepts any source string
- Automatic source resolution via `ResolverPipeline`
- `PrefixResolver` — resolves `assets/`, `http://`, and `https://` prefixes
- `ExtensionResolver` — resolves `.svg`, `.png`, `.jpg`, `.jpeg`, `.webp`, `.gif` extensions
- `NetworkRasterRenderer` — renders network raster images via `cached_network_image`
- `AssetRasterRenderer` — renders asset raster images via `Image.asset`
- `NetworkSvgRenderer` — renders network SVG images via `flutter_svg`
- `AssetSvgRenderer` — renders asset SVG images via `flutter_svg`
- `format` override param — allows explicit format override when auto-resolution is insufficient
- `placeholder` and `errorWidget` params for loading and error states
- Full unit test coverage for resolver layer