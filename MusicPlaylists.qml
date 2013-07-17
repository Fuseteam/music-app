/*
 * Copyright (C) 2013 Daniel Holm <d.holmen@gmail.com>
                      Victor Thompson <victor.thompson@gmail.com>
 *
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

import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1
import Ubuntu.Components.Popups 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import org.nemomobile.folderlistmodel 1.0
import QtMultimedia 5.0
import QtQuick.LocalStorage 2.0
import "settings.js" as Settings
import "meta-database.js" as Library
import "playing-list.js" as PlayingList
import "scrobble.js" as Scrobble
import "playlists.js" as Playlists


Page {
    property int filelistCurrentIndex: 0
    property int filelistCount: 0
    property string oldPlaylistName: ""
    property string oldPlaylistIndex: ""
    property string oldPlaylistID: ""

    onFilelistCurrentIndexChanged: {
        tracklist.currentIndex = filelistCurrentIndex
    }

    title: i18n.tr("Playlists")

    // function that adds each playlist in the listmodel to show it in the app
    function addtoPlaylistModel(element,index,array) {
        console.debug("Debug: Playlist #" + index + " = " + element);
        playlistModel.append({"id": index, "name": element});
    }

    // New playlist dialog
    Component {
         id: newPlaylistDialog
         Dialog {
             id: dialogueNewPlaylist
             title: i18n.tr("New Playlist")
             text: i18n.tr("Name your playlist.")
             TextField {
                 id: playlistName
                 placeholderText: i18n.tr("Name")
             }
             ListItem.Standard {
                 id: newplaylistoutput
             }

             Button {
                 text: i18n.tr("Create")
                 onClicked: {
                     if (playlistName.text.length > 0) { // make sure something is acually inputed
                         var newList = Playlists.addPlaylist(playlistName.text)
                         if (newList === "OK") {
                             console.debug("Debug: User created a new playlist named: "+playlistName.text)
                             // add the new playlist to the tab
                             var index = Playlists.getID(); // get the latest ID
                             playlistModel.append({"id": index, "name": playlistName.text})
                         }
                         else {
                             console.debug("Debug: Something went wrong: "+newList)
                         }

                         PopupUtils.close(dialogueNewPlaylist)
                     }
                     else {
                             newplaylistoutput.text = i18n.tr("You didn't type in a name.")

                     }
                }
             }
             Button {
                 text: i18n.tr("Cancel")
                 color: "grey"
                 onClicked: PopupUtils.close(dialogueNewPlaylist)
             }
         }
        }

    // Remove playlist dialog
    Component {
         id: removePlaylistDialog
         Dialog {
             id: dialogueRemovePlaylist
             title: i18n.tr("Are you sure?")
             text: i18n.tr("This will delete your playlist.")

             Button {
                 text: i18n.tr("Remove")
                 onClicked: {
                     // removing playlist
                     Playlists.removePlaylist(oldPlaylistID, oldPlaylistName) // remove using both ID and name, if playlists has similair names
                     playlistModel.remove(oldPlaylistIndex)
                     PopupUtils.close(dialogueRemovePlaylist)
                }
             }
             Button {
                 text: i18n.tr("Cancel")
                 color: "grey"
                 onClicked: PopupUtils.close(dialogueRemovePlaylist)
             }
         }
    }

    // Edit name of playlist dialog
    Component {
         id: editPlaylistDialog
         Dialog {
             id: dialogueEditPlaylist
             title: i18n.tr("Change name")
             text: i18n.tr("Enter the new playlist name")
             TextField {
                 id: playlistName
                 placeholderText: oldPlaylistName
             }
             ListItem.Standard {
                 id: newplaylistoutput
             }

             Button {
                 text: i18n.tr("Change")
                 onClicked: {
                     if (playlistName.text.length > 0) { // make sure something is acually inputed
                         var editList = Playlists.namechangePlaylist(oldPlaylistName,playlistName.text) // change the name of the playlist in DB
                         console.debug("Debug: User changed name from "+oldPlaylistName+" to "+playlistName.text)
                         playlistModel.set(oldPlaylistIndex, {"name": playlistName.text})
                         PopupUtils.close(dialogueEditPlaylist)
                     }
                     else {
                             newplaylistoutput.text = i18n.tr("You didn't type in a name.")

                     }
                }
             }
             Button {
                 text: i18n.tr("Cancel")
                 color: "grey"
                 onClicked: PopupUtils.close(dialogueEditPlaylist)
             }
         }
    }

    // Popover to change name and remove playlists
    Component {
        id: playlistPopoverComponent
        Popover {
            id: playlistPopover
            Column {
                id: containerLayout
                anchors {
                left: parent.left
                top: parent.top
                right: parent.right
            }
                ListItem.Standard {
                    text: i18n.tr("Change name")
                    onClicked: {
                        console.debug("Debug: Change name of playlist.")
                        PopupUtils.open(editPlaylistDialog, mainView)
                        PopupUtils.close(playlistPopover)
                    }
                }
                ListItem.Standard {
                    text: i18n.tr("Remove")
                    onClicked: {
                        console.debug("Debug: Remove playlist.")
                        PopupUtils.open(removePlaylistDialog, mainView)
                        PopupUtils.close(playlistPopover)
                    }
                }
            }
        }
    }


    tools: ToolbarItems {
        // import playlist from lastfm
        ToolbarButton {
            objectName: "lastfmplaylistaction"

            iconSource: Qt.resolvedUrl("images/lastfm.png")
            text: i18n.tr("Import")

            onTriggered: {
                console.debug("Debug: User pressed action to import playlist from lastfm")
                Scrobble.getPlaylists(Settings.getSetting("lastfmusername"))
            }
        }

        // Add playlist
        ToolbarButton {
            id: playlistAction
            objectName: "playlistaction"
            iconSource: Qt.resolvedUrl("images/playlist.png")
            text: i18n.tr("New")
            onTriggered: {
                console.debug("Debug: User pressed add playlist")
                // show new playlist dialog
                PopupUtils.open(newPlaylistDialog, mainView)
            }
        }

        // Settings dialog
        ToolbarButton {
            objectName: "settingsaction"
            iconSource: Qt.resolvedUrl("images/settings.png")
            text: i18n.tr("Settings")

            onTriggered: {
                console.debug('Debug: Show settings')
                PopupUtils.open(Qt.resolvedUrl("MusicSettings.qml"), mainView,
                                {
                                    title: i18n.tr("Settings")
                                } )
            }
        }

        // Queue dialog
        ToolbarButton {
            objectName: "queuesaction"
            iconSource: Qt.resolvedUrl("images/queue.png")
            text: i18n.tr("Queue")

            onTriggered: {
                console.debug('Debug: Show queue')
                PopupUtils.open(Qt.resolvedUrl("QueueDialog.qml"), mainView,
                                {
                                    title: i18n.tr("Queue")
                                } )
            }
        }
    }


    Component.onCompleted: {
        random = Settings.getSetting("shuffle") == "1" // shuffle state
        scrobble = Settings.getSetting("scrobble") == "1" // scrobble state
        lastfmusername = Settings.getSetting("lastfmusername") // lastfm username
        lastfmpassword = Settings.getSetting("lastfmpassword") // lastfm password

        // get playlists in an array
        var playlist = Playlists.getPlaylists(); // get the playlist from the database
        console.debug("Debug: Playlists: "+playlist) //debug
        playlist.forEach(addtoPlaylistModel) // send each item on playlist array to the model to show it
    }

    Component {
        id: highlight
        Rectangle {
            width: 5; height: 40
            color: "#DD4814";
            Behavior on y {
                SpringAnimation {
                    spring: 3
                    damping: 0.2
                }
            }
        }
    }

    ListView {
        id: tracklist
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.bottomMargin: units.gu(8)
        model: playlistModel
        delegate: playlistDelegate
        onCountChanged: {
            console.log("onCountChanged: " + tracklist.count)
        }
        onCurrentIndexChanged: {
            console.log("tracklist.currentIndex = " + tracklist.currentIndex)
        }
        onModelChanged: {
            console.log("PlayingList cleared")
        }

        Component {
            id: playlistDelegate
            ListItem.Standard {
                id: playlist
                icon: Qt.resolvedUrl("images/playlist.png")
                iconFrame: false
                text: name

                onFocusChanged: {
                    if (focus == false) {
                        selected = false
                    } else {
                        selected = false
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: {
                    }
                    onPressAndHold: {
                        console.debug("Debug: Pressed and held playlist "+name+" : "+index)
                        // show a dialog to change name and remove list
                        oldPlaylistName = name
                        oldPlaylistID = id
                        oldPlaylistIndex = index
                        PopupUtils.open(playlistPopoverComponent, mainView)
                    }
                    onClicked: {
                        if (focus == false) {
                            focus = true
                        }
                        console.log("Debug: Playlist chosen: " + name)
                    }
                }
            }
        }
    }
}
