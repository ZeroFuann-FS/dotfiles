import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM

PlasmoidItem {
    id: root

    Plasmoid.icon: connectionIcon.connectionIcon
    toolTipMainText: "Wi-Fi"
    toolTipSubText: networkStatus.activeConnections
    switchWidth: Kirigami.Units.gridUnit * 14
    switchHeight: Kirigami.Units.gridUnit * 14

    PlasmaNM.NetworkStatus { id: networkStatus }
    PlasmaNM.ConnectionIcon { id: connectionIcon }
    PlasmaNM.Handler { id: handler }
    PlasmaNM.EnabledConnections { id: enabledConnections }
    PlasmaNM.NetworkModel { id: connectionModel }
    PlasmaNM.AppletProxyModel { id: proxyModel; sourceModel: connectionModel }

    onExpandedChanged: function() { if (root.expanded) handler.requestScan() }

    compactRepresentation: MouseArea {
        hoverEnabled: true
        onClicked: root.expanded = !root.expanded
        Kirigami.Icon {
            anchors.fill: parent
            source: connectionIcon.connectionIcon
            active: parent.containsMouse
        }
    }

    fullRepresentation: FullView {
        Layout.preferredWidth: Kirigami.Units.gridUnit * 19
        Layout.preferredHeight: Kirigami.Units.gridUnit * 22
        Layout.minimumWidth: Kirigami.Units.gridUnit * 15
        Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    }
}
