import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.volume

RowLayout {
    id: app
    required property var model
    readonly property var obj: model.PulseObject
    readonly property var props: model.Properties || ({})
    readonly property string appName: props["application.name"] || (model.Client ? model.Client.name : "") || model.Name
    readonly property string appIcon: props["application.icon_name"] || (model.Client ? String(model.Client.name).toLowerCase() : "") || "applications-multimedia"

    readonly property bool hidden: appName === "plasmashell" || String(props["application.process.binary"] || "") === "plasmashell"
    visible: !hidden
    height: hidden ? 0 : implicitHeight
    width: ListView.view ? ListView.view.width : 0
    spacing: Kirigami.Units.smallSpacing * 2

    VolumeMonitor { id: meter; target: root.expanded ? app.obj : null }

    Kirigami.Icon {
        implicitWidth: Kirigami.Units.iconSizes.medium
        implicitHeight: implicitWidth
        source: app.appIcon
        fallback: "applications-multimedia"
    }
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        RowLayout {
            Layout.fillWidth: true
            PlasmaComponents3.Label {
                Layout.fillWidth: true
                text: app.appName
                elide: Text.ElideRight
            }
            EqBars { level: app.obj && app.obj.muted ? 0 : meter.volume }
        }
        PillSlider {
            Layout.fillWidth: true
            barHeight: Kirigami.Units.gridUnit * 1.0
            fillOpacity: 0.5
            value: app.obj ? app.obj.volume / root.normal : 0
            live: 0
            muted: app.obj ? app.obj.muted : false
            iconName: app.obj && app.obj.muted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"
            onMoved: v => root.setVolume(app.obj, v)
            onIconClicked: if (app.obj) app.obj.muted = !app.obj.muted
        }
    }
}
