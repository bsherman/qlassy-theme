# Qlassy

Qlassy is a pair of KDE Plasma 6 global themes built from Klassy's bottom-panel setup and Qogir icons.

Qlassy is an opinionated wrapper, not an independent visual stack. It combines Klassy's Windows 11-inspired appearance with Qogir icons and depends on both projects being installed. It does not bundle, replace, or claim ownership of Klassy or Qogir.

| Theme | Base | Icons |
| --- | --- | --- |
| Qlassy Light | Klassy Light - Bottom Panel | Qogir-Light |
| Qlassy Dark | Klassy Dark - Bottom Panel | Qogir-Dark |

The first installation loads Klassy's `Defenestrated 11` window-decoration preset. It keeps the preset's 1 px contrast outline and disables `ColorizeWindowOutlineWithButton`.

## Prerequisites

Install Klassy and both Qogir icon variants before installing Qlassy. Qlassy checks for these required components:

- Klassy application style, window decoration, color schemes, Plasma styles, and bottom-panel layout template
- `Qogir-Light` and `Qogir-Dark`
- Plasma 6's `kpackagetool6`, `kreadconfig6`, and `klassy-settings`

Qlassy does not install any of these dependencies.

## Install

```bash
./install.sh
```

Installation registers both themes, copies their previews from the matching installed Klassy theme, and does not activate either one or change Plasma's day/night schedule. Qlassy does not store preview assets in its repository.

Later runs preserve your Klassy customization. To deliberately restore the Qlassy Klassy preset, run:

```bash
./install.sh --apply-preset
```

## Use

Apply a theme in System Settings > Colors & Themes > Global Theme.

For the Qlassy bottom-panel layout, apply one Qlassy theme from the Global Theme page and include its desktop layout. This creates the panel through Klassy's `org.kde.klassy.plasma.desktop.bottomPanel` template and enables battery percentage display. It does not change screen-edge actions.

For automatic day/night switching, configure Plasma's light/dark global-theme setting with:

- Light: `Qlassy Light`
- Dark: `Qlassy Dark`

Plasma switches the color scheme, icons, application style, Plasma style, and Klassy decoration automatically. The desktop layout is only applied when explicitly selected from the Global Theme page.

Plasma global themes cannot set arbitrary Klassy configuration. Qlassy applies the shared window-decoration preset at installation time, not on every light/dark switch.

## Remove

```bash
./uninstall.sh
```

Removal refuses if either Qlassy theme is active or assigned to automatic switching. Use `./uninstall.sh --force` only after selecting another theme or when you intend to repair those settings manually.

Removal leaves Klassy, Qogir, and your Klassy configuration untouched.

## License and credits

Qlassy is licensed under LGPL-2.1-or-later. Its layout depends on [Klassy](https://github.com/paulmcauley/klassy), created by Paul A McAuley and licensed under LGPL. [Qogir Icon Theme](https://github.com/vinceliuice/Qogir-icon-theme/) is a separate required dependency and remains subject to its upstream license.
