import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property string helper: Qt.resolvedUrl("../code/estado.sh").toString().replace("file://", "")

    // Widgets de Plasma que viven escondidos en la bandeja: [id del applet, nombre, ícono]
    readonly property var systemItems: [
        [418, "Notificaciones", "notifications-symbolic"],
        [309, "Energía y batería", "battery-good-symbolic"],
        [297, "Discos y dispositivos", "drive-removable-media-symbolic"],
        [292, "KDE Connect", "kdeconnect-symbolic"],
        [312, "Reproductor", "media-playback-start-symbolic"],
        [296, "Portapapeles", "edit-paste-symbolic"],
        [303, "Pantalla", "video-display-symbolic"],
        [306, "Clima", "weather-few-clouds-symbolic"],
        [298, "Método de entrada", "input-keyboard-symbolic"],
        [293, "Cajas fuertes", "folder-locked-symbolic"]
    ]
    property var apps: []   // [{svc, path, title, icon}]

    Plasma5Support.DataSource {
        id: exec
        engine: "executable"
        onNewData: function(source, data) {
            if (source.endsWith(" sni")) {
                const out = (data["stdout"] || "").trim()
                root.apps = out.length === 0 ? [] : out.split("\n").map(l => {
                    const f = l.split("\t")
                    return { svc: f[0], path: f[1], title: f[2], icon: f[3] }
                })
            }
            disconnectSource(source)
        }
        function run(args) { connectSource("'" + root.helper + "' " + args) }
    }

    function refresh() { exec.run("sni") }
    function openApplet(id) { root.expanded = false; exec.run("applet " + id) }
    function openApp(a) { root.expanded = false; exec.run("activate '" + a.svc + "' '" + a.path + "'") }

    onExpandedChanged: function() { if (root.expanded) refresh() }
    Component.onCompleted: refresh()

    Plasmoid.icon: "view-app-grid-symbolic"
    Plasmoid.status: PlasmaCore.Types.ActiveStatus
    toolTipMainText: "Estado"
    toolTipSubText: "Batería, dispositivos, portapapeles y más"
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 12

    compactRepresentation: MouseArea {
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
        Kirigami.Icon {
            anchors.fill: parent
            source: Plasmoid.icon
            active: parent.containsMouse
        }
    }

    fullRepresentation: FullView {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 21
        Layout.preferredHeight: Kirigami.Units.gridUnit * 27
        Layout.minimumWidth: Kirigami.Units.gridUnit * 16
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    }
}
