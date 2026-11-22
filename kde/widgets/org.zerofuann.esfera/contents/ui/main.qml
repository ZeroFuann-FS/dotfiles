import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

// Esfera de puntos 3D que gira, flota rebotando dentro del widget
// y late con los bajos (relay de plainspectrum en http://127.0.0.1:8788).
// Hazlo grande en el escritorio: la esfera recorre todo su espacio.
PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    property real bajo: 0          // 0–1 suavizado
    property bool esperando: false
    Timer {
        interval: 66; running: true; repeat: true
        onTriggered: {
            if (root.esperando) return;
            root.esperando = true;
            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = () => {
                if (xhr.readyState !== XMLHttpRequest.DONE) return;
                root.esperando = false;
                if (xhr.status !== 200) return;
                const v = xhr.responseText.trim().split(",").slice(0, 3)
                          .reduce((a, b) => a + (Number(b) || 0), 0) / 3000;
                root.bajo = v > root.bajo ? Math.min(1, v) : root.bajo * 0.85 + v * 0.15;
            };
            xhr.open("GET", "http://127.0.0.1:8788/?bars=12&mono=1");
            xhr.send();
        }
    }

    fullRepresentation: Item {
        id: area
        Layout.minimumWidth: Kirigami.Units.gridUnit * 10
        Layout.minimumHeight: Kirigami.Units.gridUnit * 10
        Layout.preferredWidth: Kirigami.Units.gridUnit * 40
        Layout.preferredHeight: Kirigami.Units.gridUnit * 25

        readonly property real radioBase: Math.min(75, Math.min(width, height) * 0.3)

        // Puntos en una esfera (espiral de Fibonacci)
        readonly property var puntos: {
            const n = 340, lista = [];
            const dorado = Math.PI * (3 - Math.sqrt(5));
            for (let i = 0; i < n; i++) {
                const y = 1 - (i / (n - 1)) * 2;
                const r = Math.sqrt(1 - y * y);
                const t = dorado * i;
                lista.push([Math.cos(t) * r, y, Math.sin(t) * r]);
            }
            return lista;
        }

        property real angulo: 0
        property real px: width / 2
        property real py: height / 2
        property real vx: 0.55
        property real vy: 0.35

        Timer {
            interval: 42; running: area.visible; repeat: true
            onTriggered: {
                area.angulo += 0.015 + root.bajo * 0.035;
                const r = area.radioBase * (1 + root.bajo * 0.25) + 6;
                area.px += area.vx * 1.27; area.py += area.vy * 1.27;
                if (area.px < r) { area.px = r; area.vx = Math.abs(area.vx); }
                if (area.px > area.width - r) { area.px = area.width - r; area.vx = -Math.abs(area.vx); }
                if (area.py < r) { area.py = r; area.vy = Math.abs(area.vy); }
                if (area.py > area.height - r) { area.py = area.height - r; area.vy = -Math.abs(area.vy); }
                lienzo.requestPaint();
            }
        }

        Canvas {
            id: lienzo
            anchors.fill: parent
            renderTarget: Canvas.FramebufferObject
            renderStrategy: Canvas.Cooperative
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                const R = area.radioBase * (1 + root.bajo * 0.25);
                const cx = area.px, cy = area.py;
                const ca = Math.cos(area.angulo), sa = Math.sin(area.angulo);
                const inc = 0.42, ci = Math.cos(inc), si = Math.sin(inc);

                // halo
                const g = ctx.createRadialGradient(cx, cy, R * 0.6, cx, cy, R * 1.35);
                g.addColorStop(0, "rgba(255,255,255,0)");
                g.addColorStop(0.55, "rgba(255,255,255," + (0.10 + root.bajo * 0.25) + ")");
                g.addColorStop(1, "rgba(255,255,255,0)");
                ctx.fillStyle = g;
                ctx.beginPath(); ctx.arc(cx, cy, R * 1.35, 0, Math.PI * 2); ctx.fill();

                // puntos, agrupados en 5 niveles de profundidad (un color por grupo)
                const pts = area.puntos, NIV = 5, grupos = [[], [], [], [], []];
                for (let i = 0; i < pts.length; i++) {
                    const p = pts[i];
                    const x = p[0] * ca + p[2] * sa;
                    let z = -p[0] * sa + p[2] * ca;
                    const y = p[1] * ci - z * si;
                    z = p[1] * si + z * ci;
                    const prof = (z + 1) / 2;            // 0 atrás, 1 adelante
                    grupos[Math.min(NIV - 1, Math.floor(prof * NIV))].push(cx + x * R, cy + y * R);
                }
                for (let g2 = 0; g2 < NIV; g2++) {
                    const prof = (g2 + 0.5) / NIV, s = 0.8 + prof * 1.6, h = s / 2, lista = grupos[g2];
                    ctx.fillStyle = "rgba(255,255,255," + (0.15 + prof * 0.85).toFixed(2) + ")";
                    for (let k = 0; k < lista.length; k += 2) ctx.fillRect(lista[k] - h, lista[k + 1] - h, s, s);
                }

                // borde brillante
                ctx.strokeStyle = "rgba(255,255,255," + (0.75 + root.bajo * 0.25) + ")";
                ctx.lineWidth = 2.2;
                ctx.beginPath(); ctx.arc(cx, cy, R + 3, 0, Math.PI * 2); ctx.stroke();
            }
        }
    }
}
