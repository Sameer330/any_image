# Changelog

All notable changes to `any_image` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---
## [0.0.2] - 2026-04-26

### Added
- `MimeResolver` — resolves image format via HTTP HEAD request for extension-less URLs
- `AsyncSourceResolver` — interface for async resolvers
- `ResolverPipeline.resolveSync` — sync-only resolution path
- `AnyImage.withMimeSniffing` — named constructor with `MimeResolver` pre-configured
- `pipeline` param on `AnyImage` — allows custom resolver pipelines

---

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