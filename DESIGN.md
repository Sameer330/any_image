# any_image — Design Document

This document describes the internal architecture of `any_image`. It is intended for contributors making structural changes. You do not need to read this to use the package.

---

## Overview

`any_image` resolves an opaque source string into a rendered Flutter widget. The caller provides a string; the package decides how to render it. No manual type specification is required.

The system is built around a two-stage pipeline:

```
source string → [Resolvers] → ResolvedSource → [Renderers] → Widget
```

---

## Core Types

### `ResolvedSource`

The handoff object between the resolver and renderer layers.

```dart
class ResolvedSource {
  final String raw;           // original source string, unchanged
  final ImageLocation? location; // network or asset
  final ImageFormat? format;     // raster or svg
}
```

Both `location` and `format` are nullable internally. Nullability signals "not yet determined" — it is resolved to a default only at the end of the pipeline, not mid-pass.

### `ImageLocation` / `ImageFormat`

Enums representing the two orthogonal axes of classification:

- **Location** — where to load from: `network` or `asset`
- **Format** — how to render: `raster` or `svg`

These are independent. A resolver may set one without the other.

---

## Resolver Layer

Resolvers classify a source string. They do not render anything.

### `SourceResolver` (sync)

```dart
abstract interface class SourceResolver {
  ResolvedSource? resolve(String source);
}
```

Returns `null` if the resolver cannot classify the source. The pipeline continues to the next resolver.

### `AsyncSourceResolver`

```dart
abstract interface class AsyncSourceResolver {
  Future<ResolvedSource?> resolve(String source);
}
```

Used when classification requires an external call (e.g. an HTTP request). Async resolvers are only invoked if format remains unresolved after the sync pass.

### Built-in Resolvers

| Resolver | Type | Responsibility |
|---|---|---|
| `PrefixResolver` | sync | Sets `location` from URI scheme (`assets/` → asset, `http(s)://` → network) |
| `ExtensionResolver` | sync | Sets `format` from file extension (`.svg` → svg, known raster extensions → raster) |
| `MagicBytesResolver` | async | Sets `format` by fetching the first 64 bytes via HTTP range request and inspecting magic bytes |

Each resolver has a single orthogonal responsibility. `PrefixResolver` never sets `format`. `ExtensionResolver` never sets `location`. This allows the pipeline to merge results from multiple resolvers cleanly.

---

## Pipeline (`ResolverPipeline`)

The pipeline does not stop at the first non-null result. It collects `location` and `format` independently across all resolvers and merges them.

```
sync pass → collect (location?, format?) from all sync resolvers
         → if format still null, run async resolvers
         → apply defaults: location ?? network, format ?? raster
```

Merge strategy uses `??=`: the first resolver to set a field wins; later resolvers cannot override it.

Async resolvers are skipped entirely if `format` is resolved during the sync pass. This avoids unnecessary HTTP requests when the extension is unambiguous.

### `resolve()` vs `resolveAsync()`

- `resolve()` — sync only, applies defaults immediately. Used when `format` is provided by the caller via the `format` override param.
- `resolveAsync()` — full pipeline including async resolvers. This is what the widget always calls internally.

Callers of `AnyImage` never interact with the pipeline directly.

---

## Magic Bytes Resolution

`MagicBytesResolver` uses HTTP range requests (`Range: bytes=0-63`) to fetch the header bytes of a network resource and detect its format from the binary signature.

Supported signatures:

| Format | Detection |
|---|---|
| PNG | `\x89PNG` at offset 0 |
| JPEG | `\xFF\xD8\xFF` at offset 0 |
| WebP | `RIFF....WEBP` at offsets 0 and 8 |
| GIF | `GIF8` at offset 0 |
| SVG | `<svg` or `<?xml` ... `<svg` within first 64 bytes |

Magic bytes are embedded by image encoders and are always present in a valid file. This makes them more reliable than `Content-Type` headers, which are set manually by backend developers and are frequently incorrect or absent.

64 bytes are fetched (rather than 12) to accommodate `<?xml`-prefixed SVGs where `<svg` may appear later in the preamble.

---

## Renderer Layer

Renderers consume a `ResolvedSource` and return a widget. Each renderer declares what it can handle via `canRender()`.

```dart
abstract interface class ImageRenderer {
  bool canRender(ResolvedSource resolved);
  Widget render(ResolvedSource resolved, { width, height, fit, placeholder, errorWidget });
}
```

### Built-in Renderers

| Renderer | Location | Format | Backed by |
|---|---|---|---|
| `NetworkRasterRenderer` | network | raster | `cached_network_image` |
| `AssetRasterRenderer` | asset | raster | `Image.asset` |
| `NetworkSvgRenderer` | network | svg | `flutter_svg` |
| `AssetSvgRenderer` | asset | svg | `flutter_svg` |

The widget iterates renderers in order and uses the first one where `canRender()` returns true. If no renderer matches, the `errorWidget` is shown (or `SizedBox.shrink()` if none is provided).

---

## Widget (`AnyImage`)

`AnyImage` is a `StatefulWidget`. State is required to manage the `http.Client` lifecycle — the client is created in `initState` and closed in `dispose`.

Resolution is triggered in `initState` and stored as a `Future<ResolvedSource>`. The `build` method uses `FutureBuilder` to handle the loading, error, and data states.

`didUpdateWidget` re-runs resolution if `source` changes, and rebuilds the pipeline if `allowMagicBytes` changes (since this affects which async resolvers are registered).

### Format Override

If the caller provides `format`, the async pipeline is bypassed. The sync pipeline runs to determine `location`, then `format` is overridden directly on the `ResolvedSource`. This avoids a network round-trip when the caller has out-of-band knowledge of the image type.

---

## Extension Points

Both `SourceResolver` and `AsyncSourceResolver` are public interfaces. Custom resolvers can be passed to `ResolverPipeline` directly. Custom renderers implement `ImageRenderer`.

In the current release, custom pipelines are not injectable via the `AnyImage` widget constructor. This is deferred to a future release.

---

## Defaults

When no resolver can determine a field, the pipeline applies:

- `location` → `ImageLocation.network`
- `format` → `ImageFormat.raster`

This matches the most common case: a plain network URL to a raster image.

---

## What This Document Does Not Cover

- Versioning and changelog — see `CHANGELOG.md`
- Public API usage — see `README.md`
- Contribution process — see `CONTRIBUTING.md`