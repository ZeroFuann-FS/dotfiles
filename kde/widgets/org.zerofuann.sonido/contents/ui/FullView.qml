import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils
import org.kde.plasma.private.volume

ColumnLayout {
    id: full
    spacing: Kirigami.Units.smallSpacing * 3

    // Entrada escalonada al abrir el cuadro
    property int stagger: 0
    Connections {
        target: root
        function onExpandedChanged() { if (root.expanded) { full.stagger = 0; staggerTimer.restart() } }
    }
    Timer { id: staggerTimer; interval: 45; repeat: true; running: true
        onTriggered: { full.stagger++; if (full.stagger > 12) stop() } }
    component Enter: Item {
        property int order: 0
        opacity: full.stagger > order ? 1 : 0
        transform: Translate { y: full.stagger > order ? 0 : 10; Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } } }
        Behavior on opacity { NumberAnimation { duration: 260 } }
    }
    component SectionLabel: PlasmaComponents3.Label {
        font.pointSize: Kirigami.Theme.smallFont.pointSize
        font.letterSpacing: 1
        opacity: 0.5
        leftPadding: Kirigami.Units.smallSpacing
    }

    // ── Volumen principal ───────────────────────────────
    VolumeMonitor { id: sinkMeter; target: root.expanded && root.sink ? root.sink : null }
    Enter {
        order: 0
        Layout.fillWidth: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        implicitHeight: hero.implicitHeight
        ColumnLayout {
            id: hero
            width: parent.width
            spacing: Kirigami.Units.smallSpacing
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.rightMargin: Kirigami.Units.smallSpacing
                PlasmaComponents3.Label {
                    Layout.fillWidth: true
                    text: root.sink ? root.sink.description : "Sin salida de audio"
                    elide: Text.ElideRight
                    opacity: 0.6
                }
                PlasmaComponents3.Label { // porcentaje que cuenta
                    property real shown: root.level * 100
                    Behavior on shown { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                    text: root.muted ? "Silencio" : Math.round(shown) + " %"
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                }
            }
            PillSlider {
                Layout.fillWidth: true
                barHeight: Kirigami.Units.gridUnit * 2.2
                value: root.level
                live: sinkMeter.volume
                muted: root.muted
                iconName: root.iconFor(root.level, root.muted)
                onMoved: v => root.setVolume(root.sink, v)
                onIconClicked: if (root.sink) root.sink.muted = !root.sink.muted
            }
        }
    }

    // ── Salidas: pastillas con resaltado que se desliza ──
    PulseObjectFilterModel {
        id: sinks
        filterOutInactiveDevices: true
        filterVirtualDevices: true
        sourceModel: SinkModel {}
    }
    Enter {
        order: 1
        visible: sinks.count > 1
        Layout.fillWidth: true
        implicitHeight: outCol.implicitHeight
        ColumnLayout {
            id: outCol
            width: parent.width
            spacing: Kirigami.Units.smallSpacing
            SectionLabel { text: "SALIDA" }
            Flow {
                id: chips
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                property Item current: null
                Rectangle { // resaltado que viaja al elegido
                    parent: chips
                    z: -1
                    visible: chips.current !== null
                    x: chips.current ? chips.current.x : 0
                    y: chips.current ? chips.current.y : 0
                    width: chips.current ? chips.current.width : 0
                    height: chips.current ? chips.current.height : 0
                    radius: height / 2
                    color: Kirigami.Theme.textColor
                    opacity: 0.88
                    Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    Behavior on y { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                }
                Repeater {
                    model: sinks
                    delegate: Item {
                        id: chip
                        required property var model
                        readonly property bool isDefault: model.Default === true
                        onIsDefaultChanged: if (isDefault) chips.current = chip
                        Component.onCompleted: if (isDefault) chips.current = chip
                        width: Math.min(lbl.implicitWidth + Kirigami.Units.gridUnit * 1.4, chips.width)
                        height: Kirigami.Units.gridUnit * 1.6
                        Rectangle { anchors.fill: parent; radius: height / 2; color: Kirigami.Theme.textColor; opacity: chip.isDefault ? 0 : (ma.containsMouse ? 0.12 : 0.07) }
                        PlasmaComponents3.Label {
                            id: lbl
                            anchors.centerIn: parent
                            width: Math.min(implicitWidth, chip.width - Kirigami.Units.gridUnit)
                            text: chip.model.Description
                            elide: Text.ElideRight
                            color: chip.isDefault ? Kirigami.Theme.backgroundColor : Kirigami.Theme.textColor
                            font.weight: chip.isDefault ? Font.DemiBold : Font.Normal
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: chip.model.PulseObject.default = true }
                    }
                }
            }
        }
    }

    // ── Apps que suenan ─────────────────────────────────
    PulseObjectFilterModel {
        id: streams
        filters: [
            { role: "VirtualStream", value: false },
            { role: "Properties", value: p => !(p && (p["application.process.binary"] === "plasmashell" || p["application.name"] === "plasmashell")) }
        ]
        sourceModel: SinkInputModel {}
    }
    Enter {
        order: 2
        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitHeight: appsCol.implicitHeight
        ColumnLayout {
            id: appsCol
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing
            SectionLabel { text: "APPS" }
            PlasmaComponents3.ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: appList.count > 0
                ListView {
                    id: appList
                    model: streams
                    spacing: Kirigami.Units.smallSpacing * 2
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    add: Transition { NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 250 } }
                    delegate: AppRow {}
                }
            }
            PlasmaComponents3.Label {
                visible: appList.count === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "Ninguna app está sonando"
                opacity: 0.45
            }
        }
    }

    // ── Micrófono ───────────────────────────────────────
    VolumeMonitor { id: micMeter; target: root.expanded && root.source ? root.source : null }
    Enter {
        order: 3
        visible: root.source !== null
        Layout.fillWidth: true
        implicitHeight: micRow.implicitHeight
        RowLayout {
            id: micRow
            width: parent.width
            spacing: Kirigami.Units.smallSpacing * 2
            PillSlider {
                Layout.fillWidth: true
                barHeight: Kirigami.Units.gridUnit * 1.5
                value: root.source ? root.source.volume / root.normal : 0
                live: micMeter.volume
                muted: root.source ? root.source.muted : true
                iconName: root.source && root.source.muted ? "microphone-sensitivity-muted-symbolic" : "audio-input-microphone-symbolic"
                onMoved: v => root.setVolume(root.source, v)
                onIconClicked: if (root.source) root.source.muted = !root.source.muted
            }
        }
    }

    Enter {
        order: 4
        Layout.fillWidth: true
        implicitHeight: cfg.implicitHeight
        PlasmaComponents3.ToolButton {
            id: cfg
            width: parent.width
            flat: true
            onClicked: KCMUtils.KCMLauncher.openSystemSettings("kcm_pulseaudio")
            contentItem: PlasmaComponents3.Label { text: "Configuración de audio…"; opacity: 0.65; leftPadding: Kirigami.Units.smallSpacing }
        }
    }
}
