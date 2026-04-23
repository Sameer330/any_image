# Roadmap

This document outlines the planned development direction for `any_image`.

It exists to help contributors understand what is being worked on, what is planned, and what is explicitly out of scope. If you want to contribute toward any of these items, open an issue first to align before writing code.

> This roadmap is directional, not a commitment. Priorities may shift as the project evolves.

---

## Current Release

### v0.0.1 — Foundation ✅

The core problem: accept any image source string and render the correct widget automatically.

- `AnyImage` widget with `source`, `width`, `height`, `fit`, `placeholder`, `errorWidget`, and `format` params
- Resolver pipeline — `PrefixResolver` + `ExtensionResolver`
- Four renderers — network raster, asset raster, network SVG, asset SVG
- Composes on `cached_network_image` and `flutter_svg`
- Full unit test coverage for resolver layer
- Supports Android, iOS, Web, macOS, Windows, Linux

---

## Upcoming

### v0.1.0 — File Support

Add support for rendering images from the local filesystem, and forward HTTP headers for authenticated network requests.

- `FileRasterRenderer` — renders local raster images via `Image.file`
- `FileSvgRenderer` — renders local SVG files via `SvgPicture.file`
- `FileResolver` — detects `file://` and `File` object inputs
- Web stub for `dart:io` — graceful unsupported error on web platform

---

### v0.2.0 — Global Defaults

Allow teams to configure package-wide defaults once instead of repeating params at every callsite.

- `AnyImageTheme` inherited widget
- `AnyImageThemeData` — configurable `placeholder`, `errorWidget`, `fit`
- Theme resolution in widget — falls back to theme if param is not set

This is the design-system adoption milestone. Teams using `any_image` as a shared component should be able to set defaults at the app level.

---

### v0.3.0 — Extensibility Registry

Open the resolver and renderer layers for external extension without forking the package.

- `AnyImage.configure()` — global registry for custom resolvers and renderers
- Custom resolver API — implement `SourceResolver` and register it
- Custom renderer API — implement `ImageRenderer` and register it

This enables third-party support for formats like Lottie, AVIF, base64 data URIs, and others without requiring changes to the core package.

---

### v0.4.0 — Builder API

Expose full control over loading and error states for teams with custom UI requirements.

- `AnyImage.builder()` named constructor
- `AnyImageState` sealed class — `AnyImageLoading`, `AnyImageLoaded`, `AnyImageError`
- Builder callback receives typed state — no more `placeholder` and `errorWidget` params needed for advanced use cases

---

### v0.5.0 — Fallback Source

Allow a secondary source to be rendered if the primary source fails.

- `fallback` param — accepts a fully configured `AnyImage` as fallback
- Fallback runs the full resolver pipeline independently
- Common pattern: fallback to a local asset placeholder when a network image fails

---

## Under Consideration

These are not planned yet but may be explored based on community feedback:

- **MIME sniffing** — detect image type from HTTP `Content-Type` header for extension-less URLs
- **Base64 data URI support** — render `data:image/png;base64,...` sources
- **Lottie support** — via a separate companion package `any_image_lottie`
- **Cached asset support** — pre-warm asset images into Flutter's `ImageCache`
- **Debug overlay** — show resolved type and renderer in debug mode for easier diagnosis
- **Headers param** — forwards custom HTTP headers to `cached_network_image` for authenticated endpoints (Bearer tokens, CDN auth, etc.)

---

## Out of Scope

The following will not be part of `any_image` regardless of requests:

- **Image processing** — cropping, filtering, transformations
- **Animated GIF controls** — play, pause, speed, and frame-level control for GIF animations. Basic GIF rendering already works via Flutter's native `Image` widget.
- **Image picking or camera access** — this is a rendering package, not a media package

---

## Contributing Toward the Roadmap

If you want to work on an upcoming item:

1. Check if there is an open issue for it
2. If not, open one and mention this roadmap item
3. Wait for maintainer acknowledgement before starting work
4. Follow the process in [CONTRIBUTING.md](CONTRIBUTING.md)

Unsolicited PRs for roadmap items without a linked issue will be closed.