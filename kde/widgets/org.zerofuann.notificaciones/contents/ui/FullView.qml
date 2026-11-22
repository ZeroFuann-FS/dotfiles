import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils
import org.kde.notificationmanager as NotificationManager

ColumnLayout {
    id: full
    spacing: Kirigami.Units.smallSpacing * 2

    // Encabezado: No molestar + Limpiar
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing * 2
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.topMargin: Kirigami.Units.smallSpacing
        PlasmaComponents3.Label { text: "No molestar"; opacity: 0.6 }
        PlasmaComponents3.Switch {
            checked: root.dnd
            onToggled: root.setDnd(checked)
        }
        Item { Layout.fillWidth: true }
        PlasmaComponents3.ToolButton {
            visible: list.count > 0
            flat: true
            onClicked: clearAnim.start()
            contentItem: PlasmaComponents3.Label { text: "Limpiar"; opacity: 0.65 }
        }
    }

    // Limpiar en cascada: las tarjetas salen una tras otra y luego se borran
    property int clearing: -1
    SequentialAnimation {
        id: clearAnim
        NumberAnimation { target: full; property: "clearing"; from: 0; to: Math.min(list.count, 10); duration: Math.min(list.count, 10) * 45 }
        PauseAnimation { duration: 220 }
        ScriptAction { script: { history.clear(NotificationManager.Notifications.ClearExpired); full.clearing = -1 } }
    }

    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: list.count > 0

        ListView {
            id: list
            model: history
            clip: true
            spacing: Kirigami.Units.smallSpacing * 2
            boundsBehavior: Flickable.StopAtBounds

            // Al abrir: entran escalonadas desde arriba
            populate: Transition {
                id: pop
                SequentialAnimation {
                    PropertyAction { property: "opacity"; value: 0 }
                    PauseAnimation { duration: pop.ViewTransition.index * 45 }
                    ParallelAnimation {
                        NumberAnimation { property: "opacity"; to: 1; duration: 260 }
                        NumberAnimation { property: "y"; from: pop.ViewTransition.destination.y - 14; duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
            // Nueva notificación: cae desde arriba
            add: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 260 }
                    NumberAnimation { property: "scale"; from: 0.92; to: 1; duration: 300; easing.type: Easing.OutBack }
                }
            }
            // Al cerrar: se va a la derecha
            remove: Transition {
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; to: 0; duration: 200 }
                    NumberAnimation { property: "x"; to: 60; duration: 220; easing.type: Easing.InCubic }
                }
            }
            displaced: Transition { NumberAnimation { properties: "y"; duration: 240; easing.type: Easing.OutCubic } }

            delegate: NotiCard {}
        }
    }

    // Vacío: campanita que se mece
    ColumnLayout {
        visible: list.count === 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: Kirigami.Units.smallSpacing * 2
        Item { Layout.fillHeight: true }
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.huge
            implicitHeight: implicitWidth
            source: root.dnd ? "notifications-disabled-symbolic" : "notifications-symbolic"
            opacity: 0.35
            transformOrigin: Item.Top
            SequentialAnimation on rotation {
                running: root.expanded && list.count === 0
                loops: 1
                NumberAnimation { to: 14; duration: 140; easing.type: Easing.OutQuad }
                NumberAnimation { to: -11; duration: 180; easing.type: Easing.InOutQuad }
                NumberAnimation { to: 7; duration: 160; easing.type: Easing.InOutQuad }
                NumberAnimation { to: -3; duration: 140 }
                NumberAnimation { to: 0; duration: 120 }
            }
        }
        PlasmaComponents3.Label {
            Layout.alignment: Qt.AlignHCenter
            text: root.dnd ? "No molestar está activado" : "Todo al día"
            opacity: 0.5
        }
        Item { Layout.fillHeight: true }
    }

    PlasmaComponents3.ToolButton {
        Layout.fillWidth: true
        flat: true
        onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_notifications")
        contentItem: PlasmaComponents3.Label { text: "Configuración de notificaciones…"; opacity: 0.65; leftPadding: Kirigami.Units.smallSpacing }
    }
}
