import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// Tarjeta de reloj: fecha arriba, hora grande, barrita con el avance del día
// y ciudad · temperatura (Open-Meteo, sin clave).
PlasmoidItem {
    id: root

    readonly property string ciudad: "Misantla"
    readonly property real latitud: 19.9325
    readonly property real longitud: -96.8508

    property date ahora: new Date()
    property string temperatura: "--"

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.ahora = new Date()
    }

    function pedirClima() {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE || xhr.status !== 200) return;
            try {
                const t = JSON.parse(xhr.responseText).current.temperature_2m;
                root.temperatura = Math.round(t) + "°";
            } catch (e) {}
        };
        xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + latitud
                 + "&longitude=" + longitud + "&current=temperature_2m&timezone=auto");
        xhr.send();
    }
    Timer {
        interval: 30 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.pedirClima()
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 12
        Layout.minimumHeight: Kirigami.Units.gridUnit * 7
        Layout.preferredWidth: Kirigami.Units.gridUnit * 16
        Layout.preferredHeight: Kirigami.Units.gridUnit * 9

        Rectangle {
            id: tarjeta
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(0.07, 0.07, 0.08, 0.62)
            border.color: Qt.rgba(1, 1, 1, 0.07)

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: tarjeta.height * 0.13
                spacing: 0

                Text {
                    text: Qt.locale("es_MX").toString(root.ahora, "dddd d MMM").toUpperCase()
                    color: Qt.rgba(1, 1, 1, 0.75)
                    font.pixelSize: Math.max(10, tarjeta.height * 0.075)
                    font.weight: Font.Bold
                    font.letterSpacing: 1
                }
                Text {
                    text: Qt.formatTime(root.ahora, "HH:mm")
                    color: "white"
                    font.pixelSize: tarjeta.height * 0.36
                    font.weight: Font.Bold
                    Layout.topMargin: -tarjeta.height * 0.02
                }
                Item { Layout.fillHeight: true }

                // Avance del día
                Rectangle {
                    Layout.fillWidth: true
                    Layout.rightMargin: tarjeta.width * 0.25
                    height: 3; radius: 2
                    color: Qt.rgba(1, 1, 1, 0.18)
                    Rectangle {
                        height: parent.height; radius: 2
                        color: "white"
                        width: parent.width * ((root.ahora.getHours() * 60 + root.ahora.getMinutes()) / 1440)
                        Behavior on width { NumberAnimation { duration: 600 } }
                    }
                }
                RowLayout {
                    Layout.topMargin: tarjeta.height * 0.06
                    spacing: 6
                    Pin {
                        tinta: Qt.rgba(1, 1, 1, 0.75)
                        Layout.preferredWidth: tarjeta.height * 0.1
                        Layout.preferredHeight: tarjeta.height * 0.1
                    }
                    Text {
                        text: root.ciudad + " · " + root.temperatura
                        color: Qt.rgba(1, 1, 1, 0.75)
                        font.pixelSize: Math.max(10, tarjeta.height * 0.075)
                        font.weight: Font.DemiBold
                    }
                }
            }
        }
    }
}
