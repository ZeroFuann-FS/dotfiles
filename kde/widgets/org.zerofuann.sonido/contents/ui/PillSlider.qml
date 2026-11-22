import QtQuick
import org.kde.kirigami as Kirigami

// Barra de volumen tipo píldora: relleno animado + nivel en vivo que "respira" con el audio.
Item {
    id: pill
    property real value: 0          // 0..1
    property real live: 0           // nivel monitoreado 0..1
    property bool muted: false
    property string iconName: ""
    property int barHeight: Kirigami.Units.gridUnit * 2
    property real fillOpacity: 0.88
    signal moved(real v)
    signal iconClicked()

    implicitHeight: barHeight

    readonly property color ink: Kirigami.Theme.textColor
    property real shown: value
    Behavior on shown { enabled: !drag.pressed; NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    Rectangle { // pista
        anchors.fill: parent
        radius: height / 2
        color: pill.ink
        opacity: 0.10
    }

    Item { // relleno recortado
        anchors.fill: parent
        clip: true
        Rectangle {
            id: fill
            width: Math.max(pill.height, pill.width * pill.shown)
            height: parent.height
            radius: height / 2
            color: pill.ink
            opacity: pill.muted ? 0.30 : pill.fillOpacity
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // brillo en vivo: crece y se encoge con el audio
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 3
                height: parent.height - 6
                radius: height / 2
                width: Math.max(0, (parent.width - pill.height) * Math.min(1, pill.live * 1.4))
                color: Kirigami.Theme.backgroundColor
                opacity: pill.muted ? 0 : 0.22
                Behavior on width { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
            }
        }
    }

    Kirigami.Icon { // ícono dentro de la barra (clic = silenciar)
        id: icon
        anchors.verticalCenter: parent.verticalCenter
        x: (pill.height - width) / 2
        width: Math.round(pill.height * 0.5); height: width
        source: pill.iconName
        color: fill.width > pill.height * 0.9 && !pill.muted ? Kirigami.Theme.backgroundColor : pill.ink
        isMask: true
        z: 2
        SequentialAnimation on scale {
            id: bounce
            running: false
            NumberAnimation { to: 0.7; duration: 90; easing.type: Easing.OutQuad }
            NumberAnimation { to: 1.15; duration: 140; easing.type: Easing.OutBack }
            NumberAnimation { to: 1.0; duration: 120 }
        }
        MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: { bounce.restart(); pill.iconClicked() }
        }
    }

    MouseArea {
        id: drag
        anchors.fill: parent
        anchors.leftMargin: pill.height
        z: 1
        cursorShape: Qt.PointingHandCursor
        function at(x) { return Math.max(0, Math.min(1, (x + pill.height) / pill.width)) }
        onPressed: mouse => pill.moved(at(mouse.x))
        onPositionChanged: mouse => { if (pressed) pill.moved(at(mouse.x)) }
        onWheel: wheel => pill.moved(Math.max(0, Math.min(1, pill.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
