import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils
import org.kde.kitemmodels as KItemModels
import org.kde.bluezqt as BluezQt
import org.kde.plasma.private.bluetooth as PlasmaBt

ColumnLayout {
    id: full
    spacing: Kirigami.Units.smallSpacing * 2

    // Encabezado: estado + interruptor (el título lo pone la bandeja)
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: Kirigami.Units.smallSpacing * 2
        Layout.rightMargin: Kirigami.Units.smallSpacing
        Layout.topMargin: Kirigami.Units.smallSpacing
        PlasmaComponents3.Label {
            text: root.btOn ? "Encendido" : "Apagado"
            opacity: 0.6
            Layout.fillWidth: true
        }
        PlasmaComponents3.Switch {
            checked: root.btOn
            enabled: root.adapter !== null
            onToggled: root.setPowered(checked)
        }
    }

    KItemModels.KSortFilterProxyModel {
        id: pairedModel
        sourceModel: BluezQt.DevicesModel { }
        filterRowCallback: function(row, parent) {
            const idx = sourceModel.index(row, 0, parent)
            return sourceModel.data(idx, KItemModels.KRoleNames.role("Paired")) === true
        }
        sortRoleName: "Connected"
        sortOrder: Qt.DescendingOrder
    }

    PlasmaComponents3.ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: root.btOn && list.count > 0

        ListView {
            id: list
            model: root.btOn ? pairedModel : null
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            section.property: "Connected"
            section.delegate: PlasmaComponents3.Label {
                required property string section
                width: ListView.view.width
                topPadding: Kirigami.Units.smallSpacing * 2
                bottomPadding: Kirigami.Units.smallSpacing
                leftPadding: Kirigami.Units.smallSpacing * 2
                text: section === "true" ? "CONECTADOS" : "MIS DISPOSITIVOS"
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.letterSpacing: 1
                opacity: 0.5
            }
            delegate: DeviceRow {}
        }
    }

    PlasmaComponents3.Label {
        visible: !root.btOn || list.count === 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        text: !root.btOn ? "Bluetooth apagado" : "No tienes dispositivos emparejados"
        opacity: 0.5
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 0
        PlasmaComponents3.ToolButton {
            flat: true
            visible: root.btOn
            onClicked: PlasmaBt.LaunchApp.launchWizard()
            contentItem: PlasmaComponents3.Label { text: "Agregar dispositivo…"; opacity: 0.65; leftPadding: Kirigami.Units.smallSpacing }
        }
        Item { Layout.fillWidth: true }
        PlasmaComponents3.ToolButton {
            flat: true
            onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_bluetooth")
            contentItem: PlasmaComponents3.Label { text: "Configuración…"; opacity: 0.65 }
        }
    }
}
