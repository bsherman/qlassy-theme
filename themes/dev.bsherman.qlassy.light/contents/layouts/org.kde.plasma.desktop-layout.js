// SPDX-FileCopyrightText: 2026 Benjamin Sherman <benjamin@holyarmy.org>
// SPDX-License-Identifier: LGPL-2.1-or-later

const existingPanelIds = panelIds.slice();

loadTemplate("org.kde.klassy.plasma.desktop.bottomPanel");

if (knownWidgetTypes.includes("AndromedaLauncher")) {
    for (const id of panelIds) {
        if (existingPanelIds.includes(id)) {
            continue;
        }

        const panel = panelById(id);
        for (const kickoff of panel.widgets("org.kde.plasma.kickoff")) {
            kickoff.remove();
        }

        const launcher = panel.addWidget("AndromedaLauncher");
        launcher.index = 0;
        launcher.currentConfigGroup = ["General"];
        launcher.writeConfig("icon", "start-here-kde-symbolic");
        launcher.writeConfig("useCustomButtonImage", false);
        launcher.reloadConfig();
    }
}
