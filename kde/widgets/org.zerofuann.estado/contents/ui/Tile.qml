import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Mosaico: aparece con la ola, se eleva al pasar el mouse y se hunde al tocarlo.
Item {
    id: tile
    property int order: 0
    property string label: ""
    property string iconName: ""
    signal activated()

    readonly property bool shown: full.wave > order
    height: Kirigami.Units.gridUnit * 3.3

    opacity: shown ? 1 : 0
    scale: !shown ? 0.82 : (ma.pressed ? 0.94 : 1)
    Behavior on opacity { NumberAnimation { duration: 240 } }
    Behavior on scale { NumberAnimation { duration: 260; easing.type: Easing.OutBack } }

    Rectangle {
        id: bg
        anchors.fill: parent
        anchors.topMargin: ma.containsMouse && !ma.pressed ? 0 : 2
        anchors.bottomMargin: ma.containsMouse && !ma.pressed ? 2 : 0
        radius: Kirigami.Units.cornerRadius * 3
        color: Kirigami.Theme.textColor
        opacity: ma.containsMouse ? 0.13 : 0.06
        Behavior on opacity { NumberAnimation { duration: 160 } }
        Behavior on anchors.topMargin { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Behavior on anchors.bottomMargin { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    }

    ColumnLayout {
        anchors.centerIn: bg
        width: bg.width - Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing
        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: implicitWidth
            source: tile.iconName.endsWith("-symbolic") ? tile.iconName : tile.iconName + "-symbolic"
            fallback: tile.iconName
            rotation: ma.containsMouse ? -6 : 0
            Behavior on rotation { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
        }
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: tile.label
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: tile.activated()
    }
}
