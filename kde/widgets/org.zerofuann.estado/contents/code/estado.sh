#!/usr/bin/env bash
# Ayudante del widget Estado: lista íconos de apps (StatusNotifierItem) y abre elementos.
case "$1" in
  sni)
    qdbus-qt6 org.kde.StatusNotifierWatcher /StatusNotifierWatcher org.kde.StatusNotifierWatcher.RegisteredStatusNotifierItems 2>/dev/null |
    while read -r item; do
      svc="${item%%/*}"; path="/${item#*/}"
      get(){ qdbus-qt6 "$svc" "$path" org.freedesktop.DBus.Properties.Get org.kde.StatusNotifierItem "$1" 2>/dev/null | head -1; }
      id=$(get Id); title=$(get Title); icon=$(get IconName); status=$(get Status)
      [ "$id" = "org.kde.DiscoverNotifier" ] && [ "$status" = "Passive" ] && continue
      printf '%s\t%s\t%s\t%s\t%s\n' "$svc" "$path" "${title:-$id}" "$icon" "$id"
    done ;;
  applet)
    qdbus-qt6 org.kde.kglobalaccel /component/plasmashell org.kde.kglobalaccel.Component.invokeShortcut "activate widget $2" ;;
  activate)
    qdbus-qt6 "$2" "$3" org.kde.StatusNotifierItem.Activate 0 0 ;;
esac
