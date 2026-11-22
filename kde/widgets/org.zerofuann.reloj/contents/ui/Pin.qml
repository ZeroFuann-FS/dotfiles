import QtQuick

// Pin de ubicación dibujado (los íconos se aplanan a una bolita en tamaño chico).
Canvas {
    id: pin
    property color tinta: "white"
    onTintaChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();
        const w = width, h = height, r = Math.min(w, h * 0.8) * 0.42, cx = w / 2, cy = r + h * 0.04;
        ctx.fillStyle = tinta;
        ctx.beginPath();
        ctx.arc(cx, cy, r, Math.PI * 0.85, Math.PI * 2.15);
        ctx.lineTo(cx, h * 0.98);
        ctx.closePath();
        ctx.fill();
        ctx.globalCompositeOperation = "destination-out";
        ctx.beginPath(); ctx.arc(cx, cy, r * 0.42, 0, Math.PI * 2); ctx.fill();
    }
}
