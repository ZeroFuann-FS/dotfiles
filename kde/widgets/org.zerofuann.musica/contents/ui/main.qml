import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mpris as Mpris
import org.kde.kirigami as Kirigami

// Tarjeta de música: portada, reproductor, canción, artista, barra de tiempo
// y controles. Elige el reproductor que suena y se salta los "fantasmas"
// (Brave deja uno registrado sin canción).
PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    Mpris.Mpris2Model { id: modelo }
    readonly property var jugador: modelo.currentPlayer
    readonly property bool hayCancion: !!(jugador && (jugador.track || jugador.artist))
    readonly property bool sonando: hayCancion && jugador.playbackStatus === Mpris.PlaybackStatus.Playing

    // Fila 0 es el multiplexor; de las demás elige: sonando con canción > con canción.
    function elegirJugador() {
        const ROL = Qt.UserRole + 1;
        let conCancion = -1, sonandoIdx = -1;
        for (let i = 1; i < modelo.rowCount(); i++) {
            const p = modelo.data(modelo.index(i, 0), ROL);
            if (!p || !(p.track || p.artist)) continue;
            if (conCancion < 0) conCancion = i;
            if (p.playbackStatus === Mpris.PlaybackStatus.Playing) { sonandoIdx = i; break; }
        }
        const elegido = sonandoIdx >= 0 ? sonandoIdx : (conCancion >= 0 ? conCancion : 0);
        if (modelo.currentIndex !== elegido) modelo.currentIndex = elegido;
    }

    property real posicion: 0   // microsegundos
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: {
            root.elegirJugador();
            if (root.jugador) {
                root.jugador.updatePosition();
                root.posicion = root.jugador.position;
            }
        }
    }

    function mmss(us) {
        const s = Math.max(0, Math.floor(us / 1000000));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    fullRepresentation: Item {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 14
        Layout.minimumHeight: Kirigami.Units.gridUnit * 8
        Layout.preferredWidth: Kirigami.Units.gridUnit * 18
        Layout.preferredHeight: Kirigami.Units.gridUnit * 11

        Rectangle {
            id: tarjeta
            anchors.fill: parent
            radius: 18
            color: Qt.rgba(0.07, 0.07, 0.08, 0.62)
            border.color: Qt.rgba(1, 1, 1, 0.07)
            readonly property real u: height / 11

            Text {
                anchors.centerIn: parent
                visible: !root.hayCancion
                text: "Nada sonando"
                color: Qt.rgba(1, 1, 1, 0.55)
                font.pixelSize: tarjeta.u * 0.7
                font.weight: Font.DemiBold
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: tarjeta.u * 0.9
                spacing: tarjeta.u * 0.3
                visible: root.hayCancion

                RowLayout {
                    spacing: tarjeta.u * 0.6
                    Item {
                        Layout.preferredWidth: tarjeta.u * 3.4
                        Layout.preferredHeight: tarjeta.u * 3.4
                        Image {
                            id: portada
                            anchors.fill: parent
                            source: root.jugador ? root.jugador.artUrl : ""
                            fillMode: Image.PreserveAspectCrop
                            visible: false
                            asynchronous: true
                        }
                        Rectangle { id: mascara; anchors.fill: parent; radius: 12; visible: false }
                        OpacityMask {
                            anchors.fill: parent
                            source: portada; maskSource: mascara
                            visible: portada.status === Image.Ready
                        }
                        Rectangle {
                            anchors.fill: parent; radius: 12
                            visible: portada.status !== Image.Ready
                            color: Qt.rgba(1, 1, 1, 0.1)
                            Kirigami.Icon {
                                anchors.centerIn: parent
                                width: parent.width * 0.45; height: width
                                source: "media-album-cover"; isMask: true; color: "white"
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: tarjeta.u * 0.1
                        Text {
                            text: "♪  " + (root.jugador ? root.jugador.identity : "").toUpperCase()
                            color: Qt.rgba(1, 1, 1, 0.75)
                            font.pixelSize: tarjeta.u * 0.45
                            font.weight: Font.Bold
                            font.letterSpacing: 1
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.jugador ? root.jugador.track : ""
                            color: "white"
                            elide: Text.ElideRight
                            font.pixelSize: tarjeta.u * 0.8
                            font.weight: Font.Bold
                        }
                        Text {
                            Layout.fillWidth: true
                            text: root.jugador ? root.jugador.artist : ""
                            color: Qt.rgba(1, 1, 1, 0.7)
                            elide: Text.ElideRight
                            font.pixelSize: tarjeta.u * 0.55
                            font.weight: Font.DemiBold
                        }
                    }
                }

                // Barra de tiempo
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: tarjeta.u * 0.3
                    spacing: tarjeta.u * 0.15
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4; radius: 2
                        color: Qt.rgba(1, 1, 1, 0.18)
                        Rectangle {
                            height: parent.height; radius: 2; color: "white"
                            width: root.jugador && root.jugador.length > 0
                                   ? parent.width * Math.min(1, root.posicion / root.jugador.length) : 0
                            Behavior on width { NumberAnimation { duration: 900 } }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.mmss(root.posicion)
                            color: Qt.rgba(1, 1, 1, 0.6); font.pixelSize: tarjeta.u * 0.42
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.jugador && root.jugador.length > 0
                                  ? "-" + root.mmss(root.jugador.length - root.posicion) : ""
                            color: Qt.rgba(1, 1, 1, 0.6); font.pixelSize: tarjeta.u * 0.42
                        }
                    }
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: tarjeta.u * 1.2
                    BotonIcono {
                        icono: "media-skip-backward"; tam: tarjeta.u * 0.8
                        onClic: root.jugador && root.jugador.Previous()
                    }
                    Rectangle {
                        Layout.preferredWidth: tarjeta.u * 1.8
                        Layout.preferredHeight: tarjeta.u * 1.8
                        radius: 10
                        color: "white"
                        scale: maPlay.pressed ? 0.9 : (maPlay.containsMouse ? 1.06 : 1)
                        Behavior on scale { NumberAnimation { duration: 140 } }
                        Kirigami.Icon {
                            anchors.centerIn: parent
                            width: parent.width * 0.5; height: width
                            source: root.sonando ? "media-playback-pause" : "media-playback-start"
                            isMask: true; color: "#141416"
                        }
                        MouseArea {
                            id: maPlay; anchors.fill: parent; hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.jugador && root.jugador.PlayPause()
                        }
                    }
                    BotonIcono {
                        icono: "media-skip-forward"; tam: tarjeta.u * 0.8
                        onClic: root.jugador && root.jugador.Next()
                    }
                }
            }
        }
    }

    component BotonIcono: Kirigami.Icon {
        property string icono
        property real tam
        signal clic()
        source: icono
        isMask: true
        color: ma.containsMouse ? "white" : Qt.rgba(1, 1, 1, 0.75)
        implicitWidth: tam; implicitHeight: tam
        scale: ma.pressed ? 0.85 : 1
        Behavior on scale { NumberAnimation { duration: 120 } }
        MouseArea {
            id: ma; anchors.fill: parent; anchors.margins: -8
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: parent.clic()
        }
    }
}
