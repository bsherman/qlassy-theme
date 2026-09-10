#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Benjamin Sherman <benjamin@holyarmy.org>
# SPDX-License-Identifier: LGPL-2.1-or-later

set -euo pipefail

readonly PACKAGE_TYPE="Plasma/LookAndFeel"
readonly PRESET_NAME="Defenestrated 11"
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly ROOT_DIR
readonly DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly MARKER_FILE="$CONFIG_HOME/qlassy-theme/defenestrated-11-applied"

apply_preset=false
activate_variant=""

usage() {
    printf 'Usage: %s [--apply-preset] [--activate light|dark]\n' "${0##*/}"
}

while (($#)); do
    case "$1" in
        --apply-preset) apply_preset=true ;;
        --activate)
            if (($# < 2)); then
                usage >&2
                exit 2
            fi
            case "$2" in
                light|dark) activate_variant="$2" ;;
                *) usage >&2; exit 2 ;;
            esac
            shift
            ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

data_dirs() {
    printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
    local dirs="${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    local old_ifs="$IFS"
    IFS=:
    local dir
    for dir in $dirs; do
        printf '%s\n' "$dir"
    done
    IFS="$old_ifs"
}

find_data_file() {
    local relative_path="$1"
    local dir
    while IFS= read -r dir; do
        if [[ -f "$dir/$relative_path" ]]; then
            printf '%s\n' "$dir/$relative_path"
            return 0
        fi
    done < <(data_dirs)
    return 1
}

require_data_file() {
    local relative_path="$1"
    if ! find_data_file "$relative_path" >/dev/null; then
        printf 'Missing prerequisite: %s\n' "$relative_path" >&2
        exit 1
    fi
}

require_command() {
    if ! command -v "$1" >/dev/null; then
        printf 'Missing prerequisite command: %s\n' "$1" >&2
        exit 1
    fi
}

require_klassy_decoration() {
    local root
    for root in /usr/lib64 /usr/lib /usr/local/lib64 /usr/local/lib; do
        if [[ -f "$root/qt6/plugins/org.kde.kdecoration3/org.kde.klassy.so" ]]; then
            return 0
        fi
    done
    printf 'Missing prerequisite: Klassy KWin decoration plugin\n' >&2
    exit 1
}

is_installed() {
    local id="$1"
    local packages
    packages="$(kpackagetool6 --type "$PACKAGE_TYPE" --list)"
    [[ "$packages" == *"$id"* ]]
}

install_package() {
    local package_path="$1"
    local id="$2"
    if is_installed "$id"; then
        kpackagetool6 --type "$PACKAGE_TYPE" --upgrade "$package_path"
    else
        kpackagetool6 --type "$PACKAGE_TYPE" --install "$package_path"
    fi
}

copy_previews() {
    local qlassy_id="$1"
    local klassy_id="$2"
    local preview_file fullscreen_file target_dir
    preview_file="$(find_data_file "plasma/look-and-feel/$klassy_id/contents/previews/preview.png")"
    fullscreen_file="$(find_data_file "plasma/look-and-feel/$klassy_id/contents/previews/fullscreenpreview.jpg")"
    target_dir="$DATA_HOME/plasma/look-and-feel/$qlassy_id/contents/previews"

    mkdir -p -- "$target_dir"
    cp --remove-destination "$preview_file" "$target_dir/preview.png"
    cp --remove-destination "$fullscreen_file" "$target_dir/fullscreenpreview.jpg"
}

activate_theme() {
    local id="dev.bsherman.qlassy.$1"

    kwriteconfig6 --group KDE --key DefaultLightLookAndFeel --notify dev.bsherman.qlassy.light
    kwriteconfig6 --group KDE --key DefaultDarkLookAndFeel --notify dev.bsherman.qlassy.dark
    plasma-apply-lookandfeel --keep-auto --apply "$id"
}

verify_preset() {
    local config_file="$CONFIG_HOME/klassy/klassyrc"
    [[ "$(kreadconfig6 --file "$config_file" --group Windeco --key ColorizeWindowOutlineWithButton --default true)" == "false" ]] \
        && [[ "$(kreadconfig6 --file "$config_file" --group WindowOutlineStyle --key WindowOutlineThickness --default 1)" == "1" ]] \
        && [[ "$(kreadconfig6 --file "$config_file" --group WindowOutlineStyle --key WindowOutlineStyleActive --default WindowOutlineContrast)" == "WindowOutlineContrast" ]] \
        && [[ "$(kreadconfig6 --file "$config_file" --group WindowOutlineStyle --key WindowOutlineStyleInactive --default WindowOutlineContrast)" == "WindowOutlineContrast" ]]
}

find_preset_file() {
    local root
    for root in /usr/lib64 /usr/lib /usr/local/lib64 /usr/local/lib; do
        local preset="$root/qt6/plugins/org.kde.kdecoration3.kcm/klassydecoration/presets/Defenestrated_11.klpw"
        if [[ -f "$preset" ]]; then
            printf '%s\n' "$preset"
            return 0
        fi
    done
    return 1
}

reload_kwin() {
    local tool
    for tool in qdbus6 qdbus qdbus-qt6; do
        if command -v "$tool" >/dev/null; then
            "$tool" org.kde.KWin /KWin org.kde.KWin.reloadConfig >/dev/null 2>&1 || true
            return
        fi
    done
}

apply_klassy_preset() {
    local preset_file
    if klassy-settings --load-windeco-preset "$PRESET_NAME"; then
        :
    else
        preset_file="$(find_preset_file)" || {
            printf 'Could not find Klassy Defenestrated 11 preset.\n' >&2
            exit 1
        }
        klassy-settings --import-preset "$preset_file"
        klassy-settings --load-windeco-preset "$PRESET_NAME"
    fi

    if ! verify_preset; then
        printf 'Klassy preset verification failed.\n' >&2
        exit 1
    fi

    mkdir -p -- "${MARKER_FILE%/*}"
    : > "$MARKER_FILE"
    reload_kwin
}

require_command kpackagetool6
require_command klassy-settings
require_command kreadconfig6
if [[ -n "$activate_variant" ]]; then
    require_command kwriteconfig6
    require_command plasma-apply-lookandfeel
fi
require_data_file color-schemes/KlassyLight.colors
require_data_file color-schemes/KlassyDark.colors
require_data_file plasma/desktoptheme/klassy-light/metadata.json
require_data_file plasma/desktoptheme/klassy-dark/metadata.json
require_data_file kstyle/themes/klassy.themerc
require_data_file plasma/layout-templates/org.kde.klassy.plasma.desktop.bottomPanel/metadata.json
require_data_file plasma/look-and-feel/org.kde.klassylightbottompanel.desktop/contents/previews/preview.png
require_data_file plasma/look-and-feel/org.kde.klassylightbottompanel.desktop/contents/previews/fullscreenpreview.jpg
require_data_file plasma/look-and-feel/org.kde.klassydarkbottompanel.desktop/contents/previews/preview.png
require_data_file plasma/look-and-feel/org.kde.klassydarkbottompanel.desktop/contents/previews/fullscreenpreview.jpg
require_data_file icons/Qogir-Light/index.theme
require_data_file icons/Qogir-Dark/index.theme
require_klassy_decoration

install_package "$ROOT_DIR/themes/dev.bsherman.qlassy.light" dev.bsherman.qlassy.light
install_package "$ROOT_DIR/themes/dev.bsherman.qlassy.dark" dev.bsherman.qlassy.dark
copy_previews dev.bsherman.qlassy.light org.kde.klassylightbottompanel.desktop
copy_previews dev.bsherman.qlassy.dark org.kde.klassydarkbottompanel.desktop

if [[ "$apply_preset" == true || ! -f "$MARKER_FILE" ]]; then
    apply_klassy_preset
fi

if [[ -n "$activate_variant" ]]; then
    activate_theme "$activate_variant"
    printf 'Installed and activated Qlassy %s.\n' "${activate_variant^}"
else
    printf 'Installed Qlassy Light and Qlassy Dark. No theme was activated.\n'
fi
