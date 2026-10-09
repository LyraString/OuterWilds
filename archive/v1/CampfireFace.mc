using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

class CampfireFace extends WatchUi.WatchFace {
    var mSleeping;

    function initialize() {
        WatchFace.initialize();
        mSleeping = true;
    }

    function onEnterSleep() {
        mSleeping = true;
    }

    function onExitSleep() {
        mSleeping = false;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var clock = System.getClockTime();
        var frame = mSleeping ? 1 : (clock.sec % 4);

        dc.setColor(0x000000, 0x000000);
        dc.clear();

        drawStars(dc, clock.sec);
        drawTime(dc, clock);
        drawLandscape(dc);
        drawFire(dc, frame, clock.sec);
    }

    function drawStars(dc, second) {
        var stars = [
            [66, 22], [112, 15], [151, 22], [185, 31],
            [43, 55], [89, 43], [169, 60], [222, 73],
            [26, 94], [61, 119], [198, 101], [238, 119],
            [37, 142], [88, 127], [165, 130], [208, 147],
            [64, 170], [220, 170], [114, 122], [177, 166]
        ];
        dc.setColor(0x555555, 0x000000);
        for (var i = 0; i < stars.size(); i += 1) {
            dc.drawPoint(stars[i][0], stars[i][1]);
        }
        dc.setColor(0xAAAAAA, 0x000000);
        dc.fillCircle(82, 24, 1);
        dc.fillCircle(200, 52, 1);
        dc.fillCircle(33, 117, 1);
        if (!mSleeping && ((second % 5) == 0)) {
            dc.drawPoint(169, 60);
            dc.drawPoint(198, 101);
        }
    }

    function drawTime(dc, clock) {
        var hour = clock.hour;
        if (!System.getDeviceSettings().is24Hour) {
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeText = hour.format("%02d") + ":" + clock.min.format("%02d");
        dc.setColor(0xFFFFFF, 0x000000);
        dc.drawText(130, 59, Graphics.FONT_NUMBER_MEDIUM,
                    timeText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(0x555555, 0x000000);
        dc.drawText(130, 107, Graphics.FONT_XTINY,
                    "BENEATH THE STARS", Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawLandscape(dc) {
        dc.setColor(0x000055, 0x000000);
        dc.fillPolygon([[0, 225], [28, 219], [60, 221], [91, 217],
                        [130, 220], [169, 218], [204, 222],
                        [236, 215], [260, 222], [260, 260], [0, 260]]);
        dc.setColor(0x000000, 0x000000);
        dc.fillPolygon([[0, 230], [35, 226], [80, 228], [115, 224],
                        [150, 225], [190, 230], [230, 226],
                        [260, 228], [260, 260], [0, 260]]);
    }

    function drawFire(dc, frame, second) {
        var tips = [153, 147, 156, 149];
        var sway = [-2, 2, 0, 3];
        var tip = tips[frame];
        var dx = sway[frame];

        dc.setColor(0x550000, 0x000000);
        dc.fillEllipse(130, 208, 30, 7);

        dc.setColor(0xAA0000, 0x000000);
        dc.fillPolygon([[111, 205], [113, 189], [120, 180],
                        [121, 188], [129 + dx, tip - 5],
                        [139, 176], [145, 189], [149, 206]]);

        dc.setColor(0xFF5500, 0x000000);
        dc.fillPolygon([[119, 202], [119, 190], [125, 178],
                        [128, 188], [132 + dx, tip + 8],
                        [139, 187], [143, 203]]);

        dc.setColor(0xFFAA00, 0x000000);
        dc.fillPolygon([[125, 202], [124, 190], [130, 183],
                        [132 + dx, tip + 19], [138, 189], [136, 203]]);

        dc.setColor(0xFFFF55, 0x000000);
        dc.fillPolygon([[130, 200], [129, 191], [132, 188],
                        [135, 194], [135, 200]]);

        dc.setColor(0xAA5500, 0x000000);
        dc.setPenWidth(5);
        dc.drawLine(111, 209, 146, 215);
        dc.drawLine(146, 208, 114, 215);
        dc.setPenWidth(1);

        dc.setColor(0xFFAA00, 0x000000);
        dc.fillCircle(130, 207, 2);
        if (!mSleeping && (second % 4 == 0)) {
            dc.fillCircle(146, 163, 1);
        }
        if (!mSleeping && (second % 7 == 0)) {
            dc.fillCircle(120, 151, 1);
        }
    }
}
