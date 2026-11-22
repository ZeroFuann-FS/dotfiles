import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// Tarjeta de clima: temperatura grande, estado, ciudad con máx/mín
// y los próximos 4 días en cuadritos. Datos de Open-Meteo (sin clave).
PlasmoidItem {
    id: root

    readonly property string ciudad: "Misantla"
    readonly property real latitud: 19.9325
    readonly property real longitud: -96.8508

    property var actual: null      // { temp, codigo, dia }
    property var dias: []          // [{ nombre, codigo, max, min }]

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    // Código WMO → [descripción, ícono]
    function info(codigo, esDia) {
        const n = esDia === false ? "-night" : "";
        if (codigo === 0) return ["Despejado", "weather-clear" + n];
        if (codigo <= 2) return ["Casi despejado", "weather-few-clouds" + n];
        if (codigo === 3) return ["Nublado", "weather-overcast"];
        if (codigo <= 48) return ["Niebla", "weather-fog"];
        if (codigo <= 57) return ["Llovizna", "weather-showers-scattered"];
        if (codigo <= 67) return ["Lluvia", "weather-showers"];
        if (codigo <= 77) return ["Nieve", "weather-snow"];
        if (codigo <= 82) return ["Chubascos", "weather-showers"];
        if (codigo <= 86) return ["Nieve", "weather-snow"];
        return ["Tormenta", "weather-storm"];
    }

    function pedir() {
        const xhr = new XMLHttpRequest();
        xhr.onreadystatechange = () => {
            if (xhr.readyState !== XMLHttpRequest.DONE || xhr.status !== 200) return;
            try {
                const d = JSON.parse(xhr.responseText);
                root.actual = {
                    temp: Math.round(d.current.temperature_2m),
                    codigo: d.current.weather_code,
                    dia: d.current.is_day === 1,
                    max: Math.round(d.daily.temperature_2m_max[0]),
                    min: Math.round(d.daily.temperature_2m_min[0])
                };
                const loc = Qt.locale("es_MX");
                const lista = [];
                for (let i = 1; i <= 4; i++) {
                    const f = new Date(d.daily.time[i] + "T12:00:00");
                    let nombre = loc.toString(f, "ddd").replace(".", "");
                    nombre = nombre.charAt(0).toUpperCase() + nombre.slice(1);
                    lista.push({ nombre: nombre, codigo: d.daily.weather_code[i],
                                 max: Math.round(d.daily.temperature_2m_max[i]) });
                }
                root.dias = lista;
            } catch (e) {}
        };
        xhr.open("GET", "https://api.open-meteo.com/v1/forecast?latitude=" + latitud
                 + "&longitude=" + longitud
                 + "&current=temperature_2m,weather_code,is_day"
                 + "&daily=weather_code,temperature_2m_max,temperature_2m_min"
                 + "&forecast_days=5&timezone=auto");
        xhr.send();
    }
    Timer {
        interval: 30 * 60 * 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.pedir()
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 10

        Rectangle {
            id: tarjeta
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(0.07, 0.07, 0.08, 0.62)
            border.color: Qt.rgba(1, 1, 1, 0.07)

            readonly property real u: height / 10   // unidad relativa

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: tarjeta.u * 0.9
                spacing: tarjeta.u * 0.25

                RowLayout {
                    spacing: tarjeta.u * 0.4
                    Text {
                        text: root.actual ? root.actual.temp + "°" : "--°"
                        color: "white"
                        font.pixelSize: tarjeta.u * 2.3
                        font.weight: Font.Bold
                    }
                    Kirigami.Icon {
                        source: root.actual ? root.info(root.actual.codigo, root.actual.dia)[1] : "weather-none-available"
                        isMask: true; color: "white"
                        Layout.preferredWidth: tarjeta.u * 1.2
                        Layout.preferredHeight: tarjeta.u * 1.2
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: tarjeta.u * 0.35
                    }
                    Text {
                        text: root.actual ? root.info(root.actual.codigo, root.actual.dia)[0] : ""
                        color: Qt.rgba(1, 1, 1, 0.75)
                        font.pixelSize: tarjeta.u * 0.6
                        font.weight: Font.DemiBold
                        Layout.alignment: Qt.AlignTop
                        Layout.topMargin: tarjeta.u * 0.65
                    }
                }

                RowLayout {
                    spacing: tarjeta.u * 0.3
                    Pin {
                        tinta: Qt.rgba(1, 1, 1, 0.75)
                        Layout.preferredWidth: tarjeta.u * 0.6
                        Layout.preferredHeight: tarjeta.u * 0.6
                    }
                    Text {
                        text: root.ciudad.toUpperCase()
                              + (root.actual ? "   ↑ " + root.actual.max + "°   ↓ " + root.actual.min + "°" : "")
                        color: Qt.rgba(1, 1, 1, 0.75)
                        font.pixelSize: tarjeta.u * 0.55
                        font.weight: Font.Bold
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: tarjeta.u * 0.35
                    Repeater {
                        model: root.dias
                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: tarjeta.u * 3.3
                            radius: 12
                            color: Qt.rgba(1, 1, 1, 0.09)
                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: tarjeta.u * 0.15
                                Text {
                                    text: modelData.nombre
                                    color: Qt.rgba(1, 1, 1, 0.8)
                                    font.pixelSize: tarjeta.u * 0.5
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Kirigami.Icon {
                                    source: root.info(modelData.codigo, true)[1]
                                    isMask: true; color: "white"
                                    Layout.preferredWidth: tarjeta.u * 0.9
                                    Layout.preferredHeight: tarjeta.u * 0.9
                                    Layout.alignment: Qt.AlignHCenter
                                }
                                Text {
                                    text: modelData.max + "°"
                                    color: "white"
                                    font.pixelSize: tarjeta.u * 0.55
                                    font.weight: Font.Bold
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
