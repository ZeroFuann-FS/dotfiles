import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: row
    required property var model

    readonly property var device: model.Device
    readonly property bool isConnected: model.Connected === true
    property bool busy: false
    readonly property int battery: device && device.battery ? device.battery.percentage : -1

    onIsConnectedChanged: busy = false

    width: ListView.view ? ListView.view.width : 0
    height: Kirigami.Units.gridUnit * 2.4

    function toggle() {
        if (!device) return
        busy = true
        const call = isConnected ? device.disconnectFromDevice() : device.connectToDevice()
        if (call) call.finished.connect(function() { row.busy = false })
    }

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.cornerRadius * 2
        color: Kirigami.Theme.textColor
        opacity: row.isConnected ? 0.09 : (hover.containsMouse ? 0.05 : 0)
        Behavior on opacity { NumberAnimation { duration: Kirigami.Units.shortDuration } }
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: row.isConnected ? Qt.ArrowCursor : Qt.PointingHandCursor
        onClicked: if (!row.isConnected && !row.busy) row.toggle()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.smallSpacing * 2
        anchors.rightMargin: Kirigami.Units.smallSpacing * 2
        spacing: Kirigami.Units.smallSpacing * 2

        Kirigami.Icon {
            implicitWidth: Kirigami.Units.iconSizes.smallMedium
            implicitHeight: implicitWidth
            source: (model.Icon || "bluetooth") + "-symbolic"
            fallback: model.Icon || "network-bluetooth-symbolic"
            opacity: row.isConnected ? 1 : 0.75
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: model.Name
                elide: Text.ElideRight
                font.weight: row.isConnected ? Font.DemiBold : Font.Normal
            }
            PlasmaComponents3.Label {
                visible: row.isConnected || row.busy
                text: row.busy ? (row.isConnected ? "Desconectando…" : "Conectando…")
                               : (row.battery >= 0 ? "Conectado · " + row.battery + " %" : "Conectado")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.55
            }
        }

        PlasmaComponents3.BusyIndicator {
            visible: row.busy
            running: row.busy
            implicitWidth: Kirigami.Units.iconSizes.small
            implicitHeight: implicitWidth
        }

        PlasmaComponents3.ToolButton {
            visible: row.isConnected && !row.busy
            text: "Desconectar"
            flat: true
            opacity: hover.containsMouse || hovered ? 1 : 0.55
            onClicked: row.toggle()
        }
    }
}
