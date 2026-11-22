import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.networkmanagement as PlasmaNM

Item {
    id: row
    required property var model

    readonly property bool isWifi: model.Type === PlasmaNM.Enums.Wireless
    readonly property bool isActive: model.ConnectionState === PlasmaNM.Enums.Activated
    readonly property bool isActivating: model.ConnectionState === PlasmaNM.Enums.Activating
    readonly property bool isSecure: model.SecurityType > PlasmaNM.Enums.NoneSecurity
    readonly property bool isSaved: model.Uuid !== ""
    property bool askPassword: false

    visible: isWifi
    width: ListView.view ? ListView.view.width : 0
    height: visible ? col.implicitHeight : 0

    function join() {
        handler.addAndActivateConnection(model.DevicePath, model.SpecificPath, pw.text)
        askPassword = false
        pw.text = ""
    }

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius * 2
        color: Kirigami.Theme.textColor
        opacity: row.isActive ? 0.09 : (hover.containsMouse ? 0.05 : 0)
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }
    }

    ColumnLayout {
        id: col
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 0

        Item {
            Layout.fillWidth: true
            implicitHeight: Kirigami.Units.gridUnit * 2.4

            MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: row.isActive ? Qt.ArrowCursor : Qt.PointingHandCursor
                onClicked: {
                    if (row.isActive || row.isActivating) return
                    if (row.isSaved)
                        handler.activateConnection(model.ConnectionPath, model.DevicePath, model.SpecificPath)
                    else if (row.isSecure)
                        row.askPassword = !row.askPassword
                    else
                        handler.addAndActivateConnection(model.DevicePath, model.SpecificPath, "")
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Kirigami.Units.smallSpacing * 2
                anchors.rightMargin: Kirigami.Units.smallSpacing * 2
                spacing: Kirigami.Units.smallSpacing * 2

                Kirigami.Icon {
                    implicitWidth: Kirigami.Units.iconSizes.smallMedium
                    implicitHeight: implicitWidth
                    source: { const g = model.Signal; return "network-wireless-signal-" + (g >= 80 ? "excellent" : g >= 55 ? "good" : g >= 30 ? "ok" : g > 5 ? "weak" : "none") + "-symbolic" }
                    fallback: "network-wireless-symbolic"
                    opacity: row.isActive ? 1 : 0.75
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    PlasmaComponents3.Label {
                        Layout.fillWidth: true
                        text: model.ItemUniqueName
                        elide: Text.ElideRight
                        font.weight: row.isActive ? Font.DemiBold : Font.Normal
                    }
                    PlasmaComponents3.Label {
                        visible: row.isActive || row.isActivating
                        text: row.isActivating ? "Conectando…" : "Conectada"
                        font.pointSize: Kirigami.Theme.smallFont.pointSize
                        opacity: 0.55
                    }
                }

                Kirigami.Icon {
                    visible: row.isSecure && !row.isActive
                    implicitWidth: Kirigami.Units.iconSizes.small
                    implicitHeight: implicitWidth
                    source: "object-locked-symbolic"
                    opacity: 0.4
                }

                PlasmaComponents3.ToolButton {
                    visible: row.isActive
                    text: "Desconectar"
                    flat: true
                    opacity: hover.containsMouse || hovered ? 1 : 0.55
                    onClicked: handler.deactivateConnection(model.ConnectionPath, model.DevicePath)
                }
            }
        }

        RowLayout {
            visible: row.askPassword
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing * 2
            Layout.rightMargin: Kirigami.Units.smallSpacing * 2
            Layout.bottomMargin: Kirigami.Units.smallSpacing * 2
            PlasmaExtras.PasswordField {
                id: pw
                Layout.fillWidth: true
                placeholderText: "Contraseña"
                onAccepted: row.join()
            }
            PlasmaComponents3.Button {
                text: "Unirse"
                enabled: pw.text.length >= 8
                onClicked: row.join()
            }
        }
    }
}
