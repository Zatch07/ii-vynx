import QtQuick

Item {
    id: root
    property real iconSize: 16
    property color color: "white"
    property int phase: 0 // 0=New, 1=Waxing Crescent, 2=First Quarter, 3=Waxing Gibbous, 4=Full, 5=Waning Gibbous, 6=Last Quarter, 7=Waning Crescent

    width: iconSize
    height: iconSize

    onPhaseChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2;
            var cy = height / 2;
            var r = Math.min(width, height) / 2 - 2;

            ctx.strokeStyle = root.color;
            ctx.fillStyle = root.color;
            ctx.lineWidth = 1.5;

            // Draw base circle outline for New Moon and background for other phases
            ctx.beginPath();
            ctx.arc(cx, cy, r, 0, 2 * Math.PI);
            ctx.stroke();

            if (root.phase === 0) {
                // New Moon: empty circle
                return;
            }
            if (root.phase === 4) {
                // Full Moon: filled circle
                ctx.fill();
                return;
            }

            ctx.beginPath();
            if (root.phase >= 1 && root.phase <= 3) {
                // Waxing (1, 2, 3) - illuminated part is on the right
                // Arc from top to bottom on the right
                ctx.arc(cx, cy, r, -Math.PI / 2, Math.PI / 2, false);
                
                // Now at bottom (cx, cy + r), curve back to top (cx, cy - r)
                if (root.phase === 2) {
                    ctx.lineTo(cx, cy - r);
                } else {
                    var factor = root.phase === 1 ? 0.5 : -0.5;
                    ctx.bezierCurveTo(cx + r * factor, cy + r * 0.552, 
                                      cx + r * factor, cy - r * 0.552, 
                                      cx, cy - r);
                }
            } else {
                // Waning (5, 6, 7) - illuminated part is on the left
                // Arc from bottom to top on the left
                ctx.arc(cx, cy, r, Math.PI / 2, -Math.PI / 2, false);
                
                // Now at top (cx, cy - r), curve back to bottom (cx, cy + r)
                if (root.phase === 6) {
                    ctx.lineTo(cx, cy + r);
                } else {
                    var factor = root.phase === 5 ? 0.5 : -0.5;
                    ctx.bezierCurveTo(cx + r * factor, cy - r * 0.552, 
                                      cx + r * factor, cy + r * 0.552, 
                                      cx, cy + r);
                }
            }
            ctx.fill();
        }
    }
}
