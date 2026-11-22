import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

PlasmaComponents3.ScrollView {
    id: full

    // Ola de entrada: cada mosaico aparece un poco después del anterior
    property int wave: 0
    Connections {
        target: root
        function onExpandedChanged() { if (root.expanded) { full.wave = 0; waveTimer.restart() } }
    }
    Timer { id: waveTimer; interval: 30; repeat: true; running: true
        onTriggered: { full.wave++; if (full.wave > 40) stop() } }

    readonly property int cols: 3
    readonly property real tileW: Math.floor((availableWidth - Kirigami.Units.smallSpacing * 3 - Kirigami.Units.smallSpacing * 2 * (cols - 1)) / cols)

    ColumnLayout {
        width: full.availableWidth
        spacing: Kirigami.Units.smallSpacing * 2

        component SectionLabel: PlasmaComponents3.Label {
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            font.letterSpacing: 1
            opacity: 0.5
            leftPadding: Kirigami.Units.smallSpacing * 2
            topPadding: Kirigami.Units.smallSpacing
        }

        SectionLabel { text: "SISTEMA" }
        Flow {
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing * 2
            Repeater {
                model: root.systemItems
                delegate: Tile {
                    required property var modelData
                    required property int index
                    order: index
                    width: full.tileW
                    label: modelData[1]
                    iconName: modelData[2]
                    onActivated: root.openApplet(modelData[0])
                }
            }
        }

        SectionLabel { text: "APPS"; visible: root.apps.length > 0 }
        Flow {
            visible: root.apps.length > 0
            Layout.fillWidth: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            spacing: Kirigami.Units.smallSpacing * 2
            Repeater {
                model: root.apps
                delegate: Tile {
                    required property var modelData
                    required property int index
                    order: root.systemItems.length + index
                    width: full.tileW
                    label: modelData.title
                    iconName: modelData.icon
                    onActivated: root.openApp(modelData)
                }
            }
        }
        Item { Layout.preferredHeight: Kirigami.Units.smallSpacing }
    }
}
