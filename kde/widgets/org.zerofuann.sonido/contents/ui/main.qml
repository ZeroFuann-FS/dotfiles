import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume

PlasmoidItem {
    id: root

    readonly property var sink: PreferredDevice.sink
    readonly property var source: PreferredDevice.source
    readonly property real normal: PulseAudio.NormalVolume
    readonly property real level: sink ? sink.volume / normal : 0
    readonly property bool muted: sink ? sink.muted : true

    function iconFor(v, m) {
        if (m || v <= 0) return "audio-volume-muted-symbolic"
        if (v < 0.34) return "audio-volume-low-symbolic"
        if (v < 0.67) return "audio-volume-medium-symbolic"
        return "audio-volume-high-symbolic"
    }
    function setVolume(obj, v) {
        if (!obj) return
        obj.volume = Math.round(Math.max(0, Math.min(1, v)) * normal)
        if (v > 0 && obj.muted) obj.muted = false
    }

    Plasmoid.icon: iconFor(level, muted)
    toolTipMainText: "Sonido"
    toolTipSubText: sink ? (muted ? "Silenciado" : Math.round(level * 100) + " % · " + sink.description) : ""
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 14

    compactRepresentation: MouseArea {
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) { if (root.sink) root.sink.muted = !root.sink.muted }
            else root.expanded = !root.expanded
        }
        onWheel: wheel => root.setVolume(root.sink, root.level + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))
        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: parent.containsMouse
        }
    }

    fullRepresentation: FullView {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 20
        Layout.preferredHeight: Kirigami.Units.gridUnit * 23
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    }
}
