/*
 * Copyright (C) 2015
 *      Andrew Hayzen <ahayzen@gmail.com>
 *      Victor Thompson <victor.thompson@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3


PageHeadState {
    id: headerState
    name: "default"
    actions: Action {
        id: searchAction
        iconName: "search"
        onTriggered: thisPage.state = "search"
    }

    property alias searchEnabled: searchAction.enabled
    property Item thisPage

    PropertyChanges {
        target: thisPage.header.trailingActionBar
        actions: headerState.actions
    }
}
