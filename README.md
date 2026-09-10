# Qlassy

Qlassy is a pair of KDE Plasma 6 global themes built from Klassy's bottom-panel setup and Qogir icons.

Qlassy is an opinionated wrapper, not an independent visual stack. It combines Klassy's Windows 11-inspired appearance with Qogir icons and depends on both projects being installed. It does not bundle, replace, or claim ownership of Klassy or Qogir.

| Theme | Base | Icons |
| --- | --- | --- |
| Qlassy Light | Klassy Light - Bottom Panel | Qogir-Light |
| Qlassy Dark | Klassy Dark - Bottom Panel | Qogir-Dark |

Each theme carries the `Defenestrated 11` border size and titlebar button layout in its `contents/defaults`, so Plasma restores them on every theme apply and day/night switch. The first installation additionally loads Klassy's `Defenestrated 11` window-decoration preset for the finer styling: it keeps the preset's 1 px contrast outline and disables `ColorizeWindowOutlineWithButton`.

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

To install, configure the Qlassy light and dark day/night theme choices, and immediately activate one variant, run one of:

```bash
./install.sh --activate light
./install.sh --activate dark
```

`--activate` configures Plasma's automatic switching on/off setting. If automatic switching is enabled, Plasma will use the selected Qlassy light and dark themes at its next scheduled transition.

## Use

Apply a theme in System Settings > Colors & Themes > Global Theme.

For the Qlassy bottom-panel layout, apply one Qlassy theme from the Global Theme page and include its desktop layout. This creates the panel through Klassy's `org.kde.klassy.plasma.desktop.bottomPanel` template and enables battery percentage display. It does not change screen-edge actions.

For automatic day/night switching, configure Plasma's light/dark global-theme setting with:

- Light: `Qlassy Light`
- Dark: `Qlassy Dark`

Plasma switches the color scheme, icons, application style, Plasma style, and Klassy decoration automatically. The desktop layout is only applied when explicitly selected from the Global Theme page.

The border size and titlebar button layout are part of each theme, so Plasma also restores them on every switch. Plasma global themes cannot set arbitrary Klassy configuration, so the finer decoration styling (the contrast outline and `ColorizeWindowOutlineWithButton`) still comes from the one-time preset applied at installation, not on every light/dark switch.

## Packaging / OS images

To install both themes into a system prefix during an image build, run as root:

```bash
./install.sh --system
```

This copies the packages into `/usr/share/plasma/look-and-feel` (override with `--packageroot DIR`) and copies their previews from the installed Klassy themes. It skips every session-only step: no preset load, no `plasma-apply-lookandfeel`, no marker file. `kpackagetool6` and `klassy-settings` are not required in this mode, but the Klassy and Qogir data files still must be present. `--system` cannot be combined with `--apply-preset` or `--activate`.

The border size and titlebar button layout ship in each theme's `contents/defaults`, so no `kwinrc` editing is needed at build time. To also default the finer `Defenestrated 11` Klassy styling for new accounts, capture `klassyrc` headlessly and install it into `/etc/skel`:

```bash
stage="$(mktemp -d)"
env -i PATH="$PATH" HOME="$stage" \
    XDG_CONFIG_HOME="$stage/.config" XDG_DATA_HOME="$stage/.local/share" \
    XDG_CACHE_HOME="$stage/.cache" QT_QPA_PLATFORM=offscreen \
    klassy-settings --load-windeco-preset "Defenestrated 11"
install -Dm644 "$stage/.config/klassy/klassyrc" /etc/skel/.config/klassy/klassyrc
```

Do not ship the `~/.config/qlassy-theme/defenestrated-11-applied` marker in `/etc/skel`. With the layout in each theme, a later user run of `./install.sh` re-applies the preset idempotently, and a planted marker would only freeze an incomplete capture.

## Remove

```bash
./uninstall.sh
```

Removal refuses if either Qlassy theme is active or assigned to automatic switching. Use `./uninstall.sh --force` only after selecting another theme or when you intend to repair those settings manually.

Removal leaves Klassy, Qogir, and your Klassy configuration untouched.

## License and credits

Qlassy is licensed under LGPL-2.1-or-later. Its layout depends on [Klassy](https://github.com/paulmcauley/klassy), created by Paul A McAuley and licensed under LGPL. [Qogir Icon Theme](https://github.com/vinceliuice/Qogir-icon-theme/) is a separate required dependency and remains subject to its upstream license.
