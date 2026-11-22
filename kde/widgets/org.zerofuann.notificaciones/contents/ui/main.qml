import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.notificationmanager as NotificationManager

PlasmoidItem {
    id: root

    NotificationManager.Settings { id: settings }
    NotificationManager.Notifications {
        id: history
        showExpired: true
        showDismissed: true
        showJobs: false
        showNotifications: true
        expandUnread: true
        groupMode: NotificationManager.Notifications.GroupDisabled
        sortMode: NotificationManager.Notifications.SortByDate
        sortOrder: Qt.DescendingOrder
        urgencies: NotificationManager.Notifications.LowUrgency | NotificationManager.Notifications.NormalUrgency | NotificationManager.Notifications.CriticalUrgency
    }

    readonly property bool dnd: {
        const until = settings.notificationsInhibitedUntil
        return !!until && !isNaN(until.getTime()) && until > new Date()
    }
    readonly property int unread: history.unreadNotificationsCount

    function setDnd(on) {
        if (on) {
            const d = new Date(); d.setFullYear(d.getFullYear() + 1)
            settings.notificationsInhibitedUntil = d
        } else {
            settings.notificationsInhibitedUntil = undefined
            settings.revokeApplicationInhibitions()
        }
        settings.save()
    }

    Plasmoid.icon: dnd ? "notifications-disabled-symbolic" : "notifications-symbolic"
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    toolTipMainText: "Notificaciones"
    toolTipSubText: dnd ? "No molestar activado" : unread > 0 ? (unread === 1 ? "1 sin leer" : unread + " sin leer") : "Todo al día"
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 14

    onExpandedChanged: function() { if (!root.expanded) history.lastRead = new Date() }

    compactRepresentation: MouseArea {
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: parent.containsMouse
        }
        Rectangle { // puntito de no leídas que late
            visible: root.unread > 0 && !root.dnd
            width: Math.round(parent.width * 0.32); height: width; radius: width / 2
            anchors.right: parent.right; anchors.top: parent.top
            color: Kirigami.Theme.textColor
            SequentialAnimation on scale {
                running: parent.visible
                loops: Animation.Infinite
                NumberAnimation { to: 1.25; duration: 700; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.0; duration: 700; easing.type: Easing.InOutSine }
            }
        }
    }

    fullRepresentation: FullView {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 21
        Layout.preferredHeight: Kirigami.Units.gridUnit * 24
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    }
}
