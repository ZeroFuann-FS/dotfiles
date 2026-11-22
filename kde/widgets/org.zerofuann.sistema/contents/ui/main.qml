import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksysguard.sensors as Sensors
import org.kde.kirigami as Kirigami

// Tres tarjetas (CPU, GPU, RAM) con porcentaje y barrita;
// abajo la red (↓ ↑) y la temperatura de la NVIDIA.
PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    Sensors.Sensor { id: cpu;  sensorId: "cpu/all/usage";               updateRateLimit: 1500 }
    Sensors.Sensor { id: gpu;  sensorId: "gpu/gpu0/usage";              updateRateLimit: 1500 }
    Sensors.Sensor { id: ram;  sensorId: "memory/physical/usedPercent"; updateRateLimit: 1500 }
    Sensors.Sensor { id: baja; sensorId: "network/all/download";        updateRateLimit: 1500 }
    Sensors.Sensor { id: sube; sensorId: "network/all/upload";          updateRateLimit: 1500 }
    Sensors.Sensor { id: gpuT; sensorId: "gpu/gpu0/temperature";        updateRateLimit: 3000 }

    function velocidad(bps) {
        const v = Number(bps) || 0;
        if (v >= 1048576) return (v / 1048576).toFixed(1) + " MB/s";
        if (v >= 1024) return Math.round(v / 1024) + " KB/s";
        return Math.round(v) + " B/s";
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 6
        Layout.preferredWidth: Kirigami.Units.gridUnit * 19
        Layout.preferredHeight: Kirigami.Units.gridUnit * 7.5

        id: area
        readonly property real u: height / 7.5

        ColumnLayout {
            anchors.fill: parent
            spacing: area.u * 0.45

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: area.u * 0.45
                Tarjeta { titulo: "CPU"; valor: cpu.value ?? 0 }
                Tarjeta { titulo: "GPU"; valor: gpu.value ?? 0 }
                Tarjeta { titulo: "RAM"; valor: ram.value ?? 0 }
            }
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: area.u * 0.2
                Layout.rightMargin: area.u * 0.2
                Text {
                    text: "↓ " + root.velocidad(baja.value) + "   ↑ " + root.velocidad(sube.value)
                    color: Qt.rgba(1, 1, 1, 0.8)
                    font.pixelSize: area.u * 0.48
                    font.weight: Font.Bold
                    style: Text.Raised; styleColor: Qt.rgba(0, 0, 0, 0.5)
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: ((gpuT.value ?? 0) > 0 ? Math.round(gpuT.value) + "°C  " : "") + "NVIDIA "
                          + ((gpu.value ?? 0) > 1 ? "activa" : "dormida")
                    color: Qt.rgba(1, 1, 1, 0.8)
                    font.pixelSize: area.u * 0.48
                    font.weight: Font.Bold
                    style: Text.Raised; styleColor: Qt.rgba(0, 0, 0, 0.5)
                }
            }
        }
    }

    component Tarjeta: Rectangle {
        property string titulo
        property real valor: 0
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 16
        color: Qt.rgba(0.07, 0.07, 0.08, 0.62)
        border.color: Qt.rgba(1, 1, 1, 0.07)

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: parent.height * 0.14
            spacing: 0
            Text {
                text: titulo
                color: Qt.rgba(1, 1, 1, 0.75)
                font.pixelSize: parent.parent.height * 0.12
                font.weight: Font.Bold
            }
            Text {
                text: Math.round(valor) + "%"
                color: "white"
                font.pixelSize: parent.parent.height * 0.26
                font.weight: Font.Bold
            }
            Item { Layout.fillHeight: true }
            Rectangle {
                Layout.fillWidth: true
                height: 4; radius: 2
                color: Qt.rgba(1, 1, 1, 0.18)
                Rectangle {
                    height: parent.height; radius: 2; color: "white"
                    width: parent.width * Math.min(1, Math.max(0, valor / 100))
                    Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.OutCubic } }
                }
            }
        }
    }
}
