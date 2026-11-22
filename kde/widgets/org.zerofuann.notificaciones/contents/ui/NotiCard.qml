import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: card
    required property var model
    required property int index

    width: ListView.view ? ListView.view.width : 0
    height: box.implicitHeight

    readonly property bool leaving: full.clearing > index
    opacity: leaving ? 0 : 1
    transform: Translate { x: card.leaving ? 60 : 0; Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.InCubic } } }
    Behavior on opacity { NumberAnimation { duration: 200 } }

    function ago(d) {
        if (!d) return ""
        const s = Math.floor((Date.now() - d.getTime()) / 1000)
        if (s < 60) return "ahora"
        if (s < 3600) return "hace " + Math.floor(s / 60) + " min"
        if (s < 86400) return "hace " + Math.floor(s / 3600) + " h"
        return Qt.formatDate(d, "d MMM")
    }

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius * 3
        color: Kirigami.Theme.textColor
        opacity: hover.containsMouse ? 0.10 : 0.06
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: card.model.hasDefaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (card.model.hasDefaultAction) history.invokeDefaultAction(history.index(card.index, 0))
    }

    ColumnLayout {
        id: box
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Kirigami.Units.smallSpacing

        RowLayout { // app + hora + cerrar
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing * 3
            Layout.rightMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing * 2
            spacing: Kirigami.Units.smallSpacing * 2
            Kirigami.Icon {
                implicitWidth: Kirigami.Units.iconSizes.small
                implicitHeight: implicitWidth
                source: card.model.applicationIconName || card.model.iconName || "notifications-symbolic"
            }
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: card.model.applicationName || ""
                elide: Text.ElideRight
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.6
            }
            PlasmaComponents3.Label {
                text: card.ago(card.model.updated || card.model.created)
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.45
            }
            PlasmaComponents3.ToolButton {
                icon.name: "window-close-symbolic"
                flat: true
                implicitWidth: Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing * 2
                implicitHeight: implicitWidth
                opacity: hover.containsMouse || hovered ? 0.8 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                onClicked: history.close(history.index(card.index, 0))
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing * 3
            Layout.rightMargin: Kirigami.Units.smallSpacing * 3
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 3
            spacing: Kirigami.Units.smallSpacing * 3
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: card.model.summary || ""
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    visible: text.length > 0
                }
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: card.model.body || ""
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    elide: Text.ElideRight
                    opacity: 0.75
                    visible: text.length > 0
                }
            }
        }
    }
}
