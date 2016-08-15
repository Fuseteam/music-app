/*
 * Copyright (C) 2016
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
import Ubuntu.Components.Popups 1.3

State {
    id: playlistHeadState
    name: "playlist"

    property PageHeader thisHeader: PageHeader {
        flickable: thisPage.flickable
        leadingActionBar {
            actions: {
                if (mainPageStack.currentPage === tabs) {
                    tabs.tabActions
                } else if (mainPageStack.depth > 1) {
                    backActionComponent
                }
            }
            objectName: "tabsLeadingActionBar"
        }
        title: thisPage.title
        trailingActionBar {
            actions: [
                Action {
                    objectName: "editPlaylist"
                    iconName: "edit"
                    onTriggered: {
                        thisPage.currentDialog = PopupUtils.open(Qt.resolvedUrl("../Dialog/EditPlaylistDialog.qml"), mainView)
                        thisPage.currentDialog.oldPlaylistName = line2
                    }
                },
                Action {
                    objectName: "deletePlaylist"
                    iconName: "delete"
                    onTriggered: {
                        thisPage.currentDialog = PopupUtils.open(Qt.resolvedUrl("../Dialog/RemovePlaylistDialog.qml"), mainView)
                        thisPage.currentDialog.oldPlaylistName = line2
                    }
                }
            ]
        }
        visible: thisPage.state === "playlist"

        Action {
            id: backActionComponent
            iconName: "back"
            onTriggered: mainPageStack.pop()
        }

        StyleHints {
            backgroundColor: mainView.headerColor
            dividerColor: Qt.darker(mainView.headerColor, 1.1)
        }
    }
    property Item thisPage

    PropertyChanges {
        target: thisPage
        header: thisHeader
    }
}
