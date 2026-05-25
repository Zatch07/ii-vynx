pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import qs
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

/**
 * Provides extra features not in Quickshell.Services.Notifications:
 *  - Persistent storage
 *  - Popup notifications, with timeout
 *  - Notification groups by app
 */
Singleton {
	id: root
    component Notif: QtObject {
        id: wrapper
        required property int notificationId
        property Notification notification
        property string appName: ""
        property list<var> actions: notification?.actions.map((action) => ({
            "identifier": action.identifier,
            "text": action.text,
        })) ?? []
        property bool popup: false
        property bool isTransient: notification?.hints.transient ?? false
        property string appIcon: notification?.appIcon ?? ""
        property string body: notification?.body ?? ""
        property string image: notification?.image ?? ""
        property string summary: notification?.summary ?? ""
        property double time
        property string urgency: notification?.urgency.toString() ?? "normal"
        property Timer timer

        onNotificationChanged: {
            if (notification === null) {
                root.discardNotification(notificationId);
            } else {
                let name = notification.appName;
                if (name === "Valent" || name.toLowerCase().includes("kdeconnect")) {
                    // Valent encodes the originating Android package in action identifiers:
                    // e.g. "app.device((..., [<('0|com.whatsapp|1|...', 'Mark as read')>]))"
                    // Extract the package between the first '0|' and next '|'
                    const actions = notification.actions;
                    let pkg = null;
                    if (actions && actions.length > 0) {
                        for (let i = 0; i < actions.length; i++) {
                            const id = actions[i].identifier;
                            // Primary: Valent GVariant format: ('0|com.package|...')
                            let m = id.match(/[|'(]0\|([a-z][a-zA-Z0-9_.]+)\|/);
                            if (!m) {
                                // Fallback: any Android-style package in the string, excluding Valent itself
                                m = id.match(/\b((?:com|org|net|io)\.[a-z][a-zA-Z0-9_.]{4,})\b/);
                                if (m && m[1].includes("andyholmes.Valent")) m = null;
                            }
                            if (m) { pkg = m[1]; break; }
                        }
                    }
                    if (pkg) {
                        // Map common package names to friendly display names
                        const pkgMap = {
                            "com.whatsapp": "WhatsApp",
                            "com.whatsapp.w4b": "WhatsApp Business",
                            "com.instagram.android": "Instagram",
                            "com.twitter.android": "Twitter",
                            "com.reddit.frontpage": "Reddit",
                            "com.discord": "Discord",
                            "com.telegram.messenger": "Telegram",
                            "org.telegram.messenger": "Telegram",
                            "com.snapchat.android": "Snapchat",
                            "com.linkedin.android": "LinkedIn",
                            "com.facebook.katana": "Facebook",
                            "com.facebook.orca": "Messenger",
                            "com.google.android.gm": "Gmail",
                            "com.google.android.apps.messaging": "Messages",
                            "com.google.android.youtube": "YouTube",
                            "com.spotify.music": "Spotify",
                            "com.netflix.mediaclient": "Netflix",
                            "com.amazon.mShop.android.shopping": "Amazon",
                            "com.phonepe.app": "PhonePe",
                            "net.one97.paytm": "Paytm",
                            "in.org.npci.upiapp": "BHIM",
                        };
                        if (pkgMap[pkg]) {
                            name = pkgMap[pkg];
                        } else {
                            const parts = pkg.split(".");
                            if (parts.length === 3) {
                                // com.somebank.android → "Somebank"
                                const seg = parts[1];
                                name = seg.charAt(0).toUpperCase() + seg.slice(1);
                            } else {
                                // reg.someapp.app.android → show whole package as-is
                                name = pkg;
                            }
                        }
                    } else {
                        // No actions: try "AppName: ..." pattern in summary
                        const match = notification.summary.match(/^([^:]+):/);
                        if (match && match[1].length < 25) name = match[1];
                    }
                }
                appName = name;
            }
        }
    }

    function notifToJSON(notif) {
        return {
            "notificationId": notif.notificationId,
            "actions": notif.actions,
            "appIcon": notif.appIcon,
            "appName": notif.appName,
            "body": notif.body,
            "image": notif.image,
            "summary": notif.summary,
            "time": notif.time,
            "urgency": notif.urgency,
        }
    }
    function notifToString(notif) {
        return JSON.stringify(notifToJSON(notif), null, 2);
    }

    component NotifTimer: Timer {
        required property int notificationId
        interval: 7000
        running: true
        onTriggered: () => {
            const index = root.list.findIndex((notif) => notif.notificationId === notificationId);
            const notifObject = root.list[index];
            print("[Notifications] Notification timer triggered for ID: " + notificationId + ", transient: " + notifObject?.isTransient);
            if (notifObject.isTransient) root.discardNotification(notificationId);
            else root.timeoutNotification(notificationId);
            destroy()
        }
    }

    property bool silent: false
    property int unread: 0
    property var filePath: Directories.notificationsPath
    property list<Notif> list: []
    property var popupList: list.filter((notif) => notif.popup);
    property bool popupInhibited: (GlobalStates?.sidebarRightOpen ?? false) || silent
    property var latestTimeForApp: ({})
    Component {
        id: notifComponent
        Notif {}
    }
    Component {
        id: notifTimerComponent
        NotifTimer {}
    }

    function stringifyList(list) {
        return JSON.stringify(list.map((notif) => notifToJSON(notif)), null, 2);
    }
    
    onListChanged: {
        // Update latest time for each app
        root.list.forEach((notif) => {
            if (!root.latestTimeForApp[notif.appName] || notif.time > root.latestTimeForApp[notif.appName]) {
                root.latestTimeForApp[notif.appName] = Math.max(root.latestTimeForApp[notif.appName] || 0, notif.time);
            }
        });
        // Remove apps that no longer have notifications
        Object.keys(root.latestTimeForApp).forEach((appName) => {
            if (!root.list.some((notif) => notif.appName === appName)) {
                delete root.latestTimeForApp[appName];
            }
        });
    }

    function appNameListForGroups(groups) {
        return Object.keys(groups).sort((a, b) => {
            // Sort by time, descending
            return groups[b].time - groups[a].time;
        });
    }

    function groupsForList(list) {
        const groups = {};
        list.forEach((notif) => {
            if (!groups[notif.appName]) {
                groups[notif.appName] = {
                    appName: notif.appName,
                    appIcon: notif.appIcon,
                    notifications: [],
                    time: 0
                };
            }
            groups[notif.appName].notifications.push(notif);
            // Always set to the latest time in the group
            groups[notif.appName].time = latestTimeForApp[notif.appName] || notif.time;
        });
        return groups;
    }

    property var groupsByAppName: groupsForList(root.list)
    property var popupGroupsByAppName: groupsForList(root.popupList)
    property list<string> appNameList: appNameListForGroups(root.groupsByAppName)
    property list<string> popupAppNameList: appNameListForGroups(root.popupGroupsByAppName)

    // Quickshell's notification IDs starts at 1 on each run, while saved notifications
    // can already contain higher IDs. This is for avoiding id collisions
    property int idOffset
    signal initDone();
    signal notify(notification: var);
    signal discard(id: int);
    signal discardAll();
    signal timeout(id: var);

    // Auto-clear notifications older than configured threshold
    Timer {
        id: autoClearTimer
        interval: 5 * 60 * 1000 // Check every 5 minutes
        repeat: true
        running: true
        onTriggered: root.clearOldNotifications()
    }

	NotificationServer {
        id: notifServer
        // actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true
        // Expose x-kde-appname so Valent/KDE Connect phone app names are available
        extraHints: ["x-kde-appname"]

        onNotification: (notification) => {
            notification.tracked = true
            const id = notification.id + root.idOffset;
            const existingIndex = root.list.findIndex((notif) => notif.notificationId === id);

            if (existingIndex !== -1) {
                const existing = root.list[existingIndex];
                existing.notification = notification;
                existing.time = Date.now();
                
                if (existing.popup && existing.timer) {
                    existing.timer.restart();
                } else if (!root.popupInhibited) {
                    existing.popup = true;
                    if (notification.expireTimeout != 0) {
                        if (existing.timer) existing.timer.destroy();
                        existing.timer = notifTimerComponent.createObject(root, {
                            "notificationId": id,
                            "interval": notification.expireTimeout < 0 ? (Config?.options.notifications.timeout ?? 7000) : notification.expireTimeout,
                        });
                    }
                }
                triggerListChange();
            } else {
                const newNotifObject = notifComponent.createObject(root, {
                    "notificationId": id,
                    "notification": notification,
                    "time": Date.now(),
                });
                root.list = [...root.list, newNotifObject];

                // Popup
                if (!root.popupInhibited) {
                    newNotifObject.popup = true;
                    if (notification.expireTimeout != 0) {
                        newNotifObject.timer = notifTimerComponent.createObject(root, {
                            "notificationId": newNotifObject.notificationId,
                            "interval": notification.expireTimeout < 0 ? (Config?.options.notifications.timeout ?? 7000) : notification.expireTimeout,
                        });
                    }
                    root.unread++;
                }
            }

            root.notify(root.list[root.list.length - 1]);
            
            // Limit list size to prevent hangs
            if (root.list.length > 500) {
                root.list = root.list.slice(-500);
            }

            notifFileView.setText(stringifyList(root.list));
        }
    }

    function markAllRead() {
        root.unread = 0;
    }

    function discardNotification(id) {
        console.log("[Notifications] Discarding notification with ID: " + id);
        const initialLength = root.list.length;
        root.list = root.list.filter(notif => notif.notificationId !== id);
        
        if (root.list.length !== initialLength) {
            notifFileView.setText(stringifyList(root.list));
            triggerListChange();
        }

        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id);
        if (notifServerIndex !== -1) {
            notifServer.trackedNotifications.values[notifServerIndex].dismiss()
        }
        root.discard(id); // Emit signal
    }

    function discardAllNotifications() {
        root.list = []
        triggerListChange()
        notifFileView.setText(stringifyList(root.list));
        notifServer.trackedNotifications.values.forEach((notif) => {
            notif.dismiss()
        })
        root.discardAll();
    }

    function cancelTimeout(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id);
        if (root.list[index] != null)
            root.list[index].timer.stop();
    }

    function timeoutNotification(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id);
        if (root.list[index] != null)
            root.list[index].popup = false;
        root.timeout(id);
    }

    function timeoutAll() {
        root.popupList.forEach((notif) => {
            root.timeout(notif.notificationId);
        })
        root.popupList.forEach((notif) => {
            notif.popup = false;
        });
    }

    function attemptInvokeAction(id, notifIdentifier) {
        console.log("[Notifications] Attempting to invoke action with identifier: " + notifIdentifier + " for notification ID: " + id);
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id);
        console.log("Notification server index: " + notifServerIndex);
        if (notifServerIndex !== -1) {
            const notifServerNotif = notifServer.trackedNotifications.values[notifServerIndex];
            const action = notifServerNotif.actions.find((action) => action.identifier === notifIdentifier);
            // console.log("Action found: " + JSON.stringify(action));
            action.invoke()
        } 
        else {
            console.log("Notification not found in server: " + id)
        }
        root.discardNotification(id);
    }

    function triggerListChange() {
        root.list = root.list.slice(0)
    }

    function clearOldNotifications() {
        const maxAgeMs = (Config?.options.notifications.clearOlderThanHours ?? 12) * 3600000;
        const cutoff = Date.now() - maxAgeMs;
        const before = root.list.length;
        root.list = root.list.filter(notif => notif.time >= cutoff);
        if (root.list.length !== before) {
            console.log("[Notifications] Auto-cleared " + (before - root.list.length) + " old notification(s).");
            notifFileView.setText(stringifyList(root.list));
            triggerListChange();
        }
    }

    function refresh() {
        notifFileView.reload()
    }

    Component.onCompleted: {
        refresh()
    }

    FileView {
        id: notifFileView
        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            const fileContents = notifFileView.text()
            const rawList = JSON.parse(fileContents);
            const deduplicated = [];
            const seenIds = new Set();
            
            // Deduplicate and limit size from file
            for (let i = rawList.length - 1; i >= 0; i--) {
                const notif = rawList[i];
                if (!seenIds.has(notif.notificationId)) {
                    deduplicated.unshift(notif);
                    seenIds.add(notif.notificationId);
                }
                if (deduplicated.length >= 500) break;
            }

            root.list = deduplicated.map((notif) => {
                return notifComponent.createObject(root, {
                    "notificationId": notif.notificationId,
                    "actions": [], // Notification actions are meaningless if they're not tracked by the server or the sender is dead
                    "appIcon": notif.appIcon,
                    "appName": notif.appName,
                    "body": notif.body,
                    "image": notif.image,
                    "summary": notif.summary,
                    "time": notif.time,
                    "urgency": notif.urgency,
                });
            });
            // Find largest notificationId
            let maxId = 0
            root.list.forEach((notif) => {
                maxId = Math.max(maxId, notif.notificationId)
            })

            console.log("[Notifications] File loaded")
            root.idOffset = maxId
            root.initDone()
            // Clear stale entries immediately on load
            root.clearOldNotifications()
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                console.log("[Notifications] File not found, creating new file.")
                root.list = []
                notifFileView.setText(stringifyList(root.list));
            } else {
                console.log("[Notifications] Error loading file: " + error)
            }
        }
    }
}
