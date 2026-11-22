import QtQuick
import org.kde.kirigami as Kirigami

// Tres barritas de ecualizador que bailan con el nivel real de la app.
Row {
    id: eq
    property real level: 0
    property bool active: level > 0.02
    spacing: 2
    height: Kirigami.Units.iconSizes.small
    Repeater {
        model: 3
        Rectangle {
            required property int index
            readonly property real factor: [0.75, 1.0, 0.55][index]
            property real wobble: 1
            width: 3
            radius: 1.5
            anchors.bottom: parent.bottom
            color: Kirigami.Theme.textColor
            opacity: eq.active ? 0.85 : 0.25
            height: Math.max(3, eq.height * (eq.active ? Math.min(1, eq.level * 1.6 * factor * wobble + 0.15) : 0.2))
            Behavior on height { NumberAnimation { duration: 110; easing.type: Easing.OutQuad } }
            SequentialAnimation on wobble {
                running: eq.active
                loops: Animation.Infinite
                NumberAnimation { to: 0.6 + 0.1 * index; duration: 180 + 70 * index; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.15; duration: 220 + 50 * index; easing.type: Easing.InOutSine }
            }
        }
    }
}
