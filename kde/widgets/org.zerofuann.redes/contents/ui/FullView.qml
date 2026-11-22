import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils
import org.kde.plasma.networkmanagement as PlasmaNM

ColumnLayout {
    id: full
    spacing: Kirigami.Units.smallSpacing * 2

    // Encabezado: título + interruptor
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing * 2
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.topMargin: Kirigami.Units.smallSpacing
        PlasmaComponents3.Label {
            text: enabledConnections.wirelessEnabled ? "Encendido" : "Apagado"
            opacity: 0.6
            Layout.fillWidth: true
        }
        PlasmaComponents3.Switch {
            checked: enabledConnections.wirelessEnabled
            onToggled: handler.enableWireless(checked)
        }
    }

    // Lista
    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: enabledConnections.wirelessEnabled

        ListView {
            id: list
            model: proxyModel
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            section.property: "Section"
            section.delegate: PlasmaComponents3.Label {
                required property string section
                width: ListView.view.width
                topPadding: Kirigami.Units.smallSpacing * 2
                bottomPadding: Kirigami.Units.smallSpacing
                leftPadding: Kirigami.Units.smallSpacing * 2
                text: section.toUpperCase()
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.letterSpacing: 1
                opacity: 0.5
            }
            delegate: NetRow {}
        }
    }

    PlasmaComponents3.Label {
        visible: !enabledConnections.wirelessEnabled
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "Wi-Fi apagado"
        opacity: 0.5
    }

    // Pie: una sola acción
    PlasmaComponents3.ToolButton {
        Layout.fillWidth: true
        flat: true
        text: "Configuración de red…"
        onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_networkmanagement")
        contentItem: PlasmaComponents3.Label {
            text: parent.text
            opacity: 0.65
            leftPadding: Kirigami.Units.smallSpacing
        }
    }
}
