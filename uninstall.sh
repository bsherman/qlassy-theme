#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Benjamin Sherman <benjamin@holyarmy.org>
# SPDX-License-Identifier: LGPL-2.1-or-later

set -euo pipefail

readonly PACKAGE_TYPE="Plasma/LookAndFeel"
force=false

usage() {
    printf 'Usage: %s [--force]\n' "${0##*/}"
}

while (($#)); do
    case "$1" in
        --force) force=true ;;
        -h|--help) usage; exit 0 ;;
        *) usage >&2; exit 2 ;;
    esac
    shift
done

require_command() {
    if ! command -v "$1" >/dev/null; then
        printf 'Missing prerequisite command: %s\n' "$1" >&2
        exit 1
    fi
}

is_qlassy_id() {
    [[ "$1" == dev.bsherman.qlassy.light || "$1" == dev.bsherman.qlassy.dark ]]
}

referenced_by_settings() {
    local key value
    for key in LookAndFeelPackage DefaultLightLookAndFeel DefaultDarkLookAndFeel; do
        value="$(kreadconfig6 --group KDE --key "$key" --default '')"
        if is_qlassy_id "$value"; then
            return 0
        fi
    done
    return 1
}

is_installed() {
    local id="$1"
    local packages
    packages="$(kpackagetool6 --type "$PACKAGE_TYPE" --list)"
    [[ "$packages" == *"$id"* ]]
}

require_command kpackagetool6
require_command kreadconfig6

if [[ "$force" == false ]] && referenced_by_settings; then
    printf 'Qlassy is active or configured for automatic switching. Use --force to remove it anyway.\n' >&2
    exit 1
fi

for id in dev.bsherman.qlassy.light dev.bsherman.qlassy.dark; do
    if is_installed "$id"; then
        kpackagetool6 --type "$PACKAGE_TYPE" --remove "$id"
    fi
done

printf 'Removed Qlassy packages. Klassy and Qogir settings were left unchanged.\n'
