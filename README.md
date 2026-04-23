# any_image

> Flutter never gave us a universal `<img>` tag. `any_image` does.

A universal Flutter image widget that automatically resolves and renders network, asset, and SVG images from a single source string. Designed to be extended, not modified.

[![pub.dev](https://img.shields.io/pub/v/any_image.svg)](https://pub.dev/packages/any_image)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20web%20|%20macos%20|%20windows%20|%20linux-lightgrey.svg)](https://pub.dev/packages/any_image)

---

## The problem

Flutter gives you `Image.network`, `Image.asset`, `SvgPicture.network`, `SvgPicture.asset` — and expects you to know which one to use before rendering. In real apps, image sources arrive as opaque strings from APIs, CMSes, or databases. You shouldn't have to inspect the source to render it.

`any_image` handles that decision for you.

---

## Installation

```yaml
dependencies:
  any_image: ^0.0.1
```

```bash
flutter pub get
```

---

## Usage

### Basic

```dart
import 'package:any_image/any_image.dart';

// Network raster
AnyImage(source: 'https://example.com/photo.jpg')

// Network SVG
AnyImage(source: 'https://example.com/logo.svg')

// Asset raster
AnyImage(source: 'assets/images/banner.png')

// Asset SVG
AnyImage(source: 'assets/icons/logo.svg')
```

That's it. `any_image` resolves the type and renders the correct widget automatically.

### With options

```dart
AnyImage(
  source: imageUrl,
  width: 200,
  height: 200,
  fit: BoxFit.cover,
  placeholder: const CircularProgressIndicator(),
  errorWidget: const Icon(Icons.broken_image),
)
```

### Override resolution

For sources where auto-resolution cannot determine the format (e.g. CDN URLs with no extension), use the `format` override:

```dart
AnyImage(
  source: 'https://cdn.example.com/a8f3k',
  format: ImageFormat.svg,
)
```

---

## How it works

`any_image` runs an ordered resolver pipeline on the source string:

1. **PrefixResolver** — detects `assets/`, `http://`, `https://`
2. **ExtensionResolver** — detects `.svg`, `.png`, `.jpg`, `.webp`, `.gif`

The resolved location and format are merged, then dispatched to the correct renderer:

| Location | Format | Renderer |
|----------|--------|----------|
| network  | raster | `CachedNetworkImage` |
| network  | svg    | `SvgPicture.network` |
| asset    | raster | `Image.asset` |
| asset    | svg    | `SvgPicture.asset` |

`any_image` does not reimplement image rendering — it composes on top of [`cached_network_image`](https://pub.dev/packages/cached_network_image) and [`flutter_svg`](https://pub.dev/packages/flutter_svg).

---

## Platform support

| Android | iOS | Web | macOS | Windows | Linux |
|---------|-----|-----|-------|---------|-------|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Roadmap

- [ ] File image support (`Image.file`, `SvgPicture.file`)
- [ ] Global defaults via `AnyImageTheme`
- [ ] Custom renderer registry via `AnyImage.configure()`
- [ ] Builder API for custom loading states
- [ ] Fallback chained source support

Check out our roadmap here: [Roadmap](ROADMAP.md)

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

---

## License

MIT © [Sameer Ankalagi](https://github.com/Sameer330)