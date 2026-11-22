import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// Barras blancas que cuelgan del borde de arriba y bailan con la música.
// Lee el relay de plainspectrum (http://127.0.0.1:8788, valores 0–1000).
PlasmoidItem {
    id: root

    readonly property int nBarras: 48
    property var niveles: new Array(nBarras).fill(0)   // 0–1 ya suavizados
    property bool hayAudio: false

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property bool esperando: false
    Timer {
        interval: 33; running: true; repeat: true
        onTriggered: {
            if (root.esperando) return;
            root.esperando = true;
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = () => {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;
                root.esperando = false;
                if (xhr.status !== 200) return;
                const crudo = xhr.responseText.trim().split(",");
                const nuevos = root.niveles.slice();
                let suma = 0;
                for (let i = 0; i < root.nBarras; i++) {
                    const v = Math.min(1, Math.sqrt((Number(crudo[i]) || 0) / 1000) * 1.15);
                    // sube rápido, baja suave
                    nuevos[i] = v > nuevos[i] ? v : nuevos[i] * 0.82 + v * 0.18;
                    suma += nuevos[i];
                }
                root.niveles = nuevos;
                root.hayAudio = suma > 0.05;
            };
            xhr.open("GET", "http://127.0.0.1:8788/?bars=" + root.nBarras + "&mono=1");
            xhr.send();
        }
    }

    fullRepresentation: Item {
        id: area
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 4
        Layout.preferredWidth: Kirigami.Units.gridUnit * 60
        Layout.preferredHeight: Kirigami.Units.gridUnit * 10

        Row {
            id: fila
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            readonly property real paso: area.width / root.nBarras
            spacing: paso * 0.35
            Repeater {
                model: root.nBarras
                Rectangle {
                    required property int index
                    width: fila.paso * 0.65
                    // siempre queda una "pestaña" visible aunque no suene nada
                    height: area.height * 0.06 + area.height * 0.94 * root.niveles[index]
                    radius: 3
                    color: "white"
                    opacity: 0.92
                    // esquinas de arriba rectas: las tapa un rectángulo pegado al borde
                    Rectangle { width: parent.width; height: Math.min(parent.height, 4); color: "white" }
                }
            }
        }
    }
}
