import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.bluezqt as BluezQt

PlasmoidItem {
    id: root

    readonly property var adapter: BluezQt.Manager.usableAdapter
    readonly property bool btOn: adapter !== null && adapter.powered && !BluezQt.Manager.bluetoothBlocked
    readonly property int connectedCount: BluezQt.Manager.connectedDevices ? BluezQt.Manager.connectedDevices.length : 0

    function setPowered(on) {
        if (on) {
            BluezQt.Manager.bluetoothBlocked = false
            if (root.adapter) root.adapter.powered = true
        } else if (root.adapter) {
            root.adapter.powered = false
        }
    }

    Plasmoid.icon: !btOn ? "network-bluetooth-inactive-symbolic"
                 : connectedCount > 0 ? "network-bluetooth-activated-symbolic"
                 : "network-bluetooth-symbolic"
    Plasmoid.status: BluezQt.Manager.adapters.length > 0 ? PlasmaCore.Types.ActiveStatus : PlasmaCore.Types.PassiveStatus
    toolTipMainText: "Bluetooth"
    toolTipSubText: !btOn ? "Apagado" : connectedCount > 0 ? (connectedCount === 1 ? "1 dispositivo conectado" : connectedCount + " dispositivos conectados") : "Sin dispositivos conectados"
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
        Layout.preferredWidth: Kirigami.Units.gridUnit * 19
        Layout.preferredHeight: Kirigami.Units.gridUnit * 18
        Layout.minimumWidth: Kirigami.Units.gridUnit * 15
        Layout.minimumHeight: Kirigami.Units.gridUnit * 12
    }
}
