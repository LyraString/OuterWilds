using Toybox.Graphics;
using Toybox.Lang;

// Original code-drawn artwork: only colors from the MIP 6-bit RGB cube.
// Coordinates are deliberately composed for the 260-pixel circular display.
class CampfireScene {
    var mStars as Lang.Array<Lang.Array<Lang.Number>> = [
        [78,16], [93,11], [108,7], [149,8], [164,13], [178,20],
        [66,23], [98,21], [116,19], [146,21], [166,25], [191,31],
        [52,35], [61,42], [74,46], [97,45], [155,46], [177,45],
        [200,39], [211,48], [219,57], [39,53], [31,66], [37,76],
        [22,83], [29,93], [17,99], [32,104], [42,110], [52,104],
        [62,112], [74,108], [84,120], [69,127], [49,130], [31,124],
        [12,122], [22,137], [16,151], [29,156], [52,143], [60,151],
        [72,143], [82,151], [91,160], [105,150], [115,160], [149,151],
        [161,162], [173,150], [181,158], [162,174], [96,174], [82,167],
        [226,73], [238,79], [231,95], [244,98], [238,110], [249,118],
        [229,124], [244,136], [252,146], [237,152], [247,167], [229,171],
        [216,111], [200,117], [181,111], [174,123], [185,129], [157,120],
        [103,126], [87,133], [117,152], [150,164], [172,136], [12,163],
        // A few distant points show through counters and spaces in the time.
        [66,99], [83,118], [104,90], [112,117], [158,87], [172,119], [192,101], [203,119]
    ];
    var mBrightStars as Lang.Array<Lang.Array<Lang.Number>> = [
        [85,25], [159,18], [188,42], [44,65], [24,114],
        [48,121], [77,133], [101,158], [155,157], [183,119],
        [226,109], [239,87], [240,130], [230,148], [18,143],
        [64,159], [180,144], [202,105], [39,91], [216,65]
    ];
    // Six MIP-safe cool-white shades rise and fall over twelve seconds.
    // Different phases keep the sky moving gently rather than flashing in unison.
    var mStarColors as Lang.Array<Lang.Number> = [
        0x555555, 0x5555AA, 0x55AAAA, 0xAAAAAA, 0xAAAAFF, 0xFFFFFF
    ];
    var mStarHalos as Lang.Array<Lang.Number> = [
        0x000055, 0x000055, 0x555555, 0x5555AA, 0x55AAAA, 0xAAAAAA
    ];
    var mPulseLevels as Lang.Array<Lang.Number> = [0,1,2,3,4,5,5,4,3,2,1,0];
    var mFireColors as Lang.Array<Lang.Number> = [0x000000, 0xAA0000, 0xFF5500, 0xFFAA00, 0xFFFFAA];
    // Six hand-drawn flame poses, each 13 x 17 logical pixels.
    // 0=transparent, 1=red edge, 2=orange, 3=gold, 4=warm core.
    var mFlames as Lang.Array<Lang.Array<Lang.String>> = [
        ["0000001000000", "0000011000000", "0000012100000", "0000002100000",
         "0000002210000", "0001002210000", "0001202320000", "0001223320100",
         "0012223321100", "0012233332100", "0122334332210", "0123344332210",
         "0123344433210", "0123344433210", "0012334432210", "0012233322100", "0001222221000"],
        ["0000000100000", "0000001100000", "0000001200000", "0000012200000",
         "0000012210000", "0000123210000", "0000123210100", "0001233211200",
         "0012233322200", "0012233332210", "0122334332210", "0123334432210",
         "0123344433210", "0012344433210", "0012334432210", "0012233322100", "0001222221000"],
        ["0000010000000", "0000011000000", "0000012100000", "0000012100000",
         "0000012210000", "0000123210000", "0000123210000", "0010123320000",
         "0011223320100", "0012223332100", "0122334332210", "0123344332210",
         "0123344433210", "0123344433210", "0012334432210", "0012233322100", "0001222221000"],
        ["0000000000000", "0000000010000", "0000000120000", "0000001220000",
         "0000001221000", "0000012321000", "0000012321000", "0000123320100",
         "0011223321100", "0012233332100", "0122334332210", "0123334432210",
         "0123344433210", "0123344433210", "0012334432210", "0012233322100", "0001222221000"],
        ["0000001000000", "0000001100000", "0000001200000", "0000012200000",
         "0000122210000", "0000123210000", "0010123210000", "0011123320000",
         "0012223321000", "0122233332100", "0122334332210", "0123344332210",
         "0123344433210", "0123344433210", "0012334432210", "0012233322100", "0001222221000"],
        ["0000000100000", "0000001200000", "0000001200000", "0000012210000",
         "0000012210000", "0000012320000", "0000012320100", "0000123321100",
         "0011223322100", "0012233332210", "0122334332210", "0123334432210",
         "0123344433210", "0123344433210", "0012334432210", "0012233322100", "0001222221000"]
    ];

    function initialize() {}

    function drawSky(dc, second, sleeping) {
        for (var i = 0; i < mStars.size(); i += 1) {
            var level = sleeping ? 3 : mPulseLevels[(second + i * 2) % 12];
            dc.setColor(mStarColors[level], Graphics.COLOR_TRANSPARENT);
            dc.drawPoint(mStars[i][0], mStars[i][1]);
        }
        for (var j = 0; j < mBrightStars.size(); j += 1) {
            var star = mBrightStars[j];
            var brightness = sleeping ? 3 : mPulseLevels[(second + j * 2 + 1) % 12];
            if (j % 3 == 0) {
                dc.setColor(mStarHalos[brightness], Graphics.COLOR_TRANSPARENT);
                dc.drawLine(star[0] - 2, star[1], star[0] + 3, star[1]);
                dc.drawLine(star[0], star[1] - 2, star[0], star[1] + 3);
            }
            dc.setColor(mStarColors[brightness], Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(star[0], star[1], 2, 2);
        }
        // A quiet, four-point navigation star above the clock.
        var guideLevel = sleeping ? 4 : mPulseLevels[second % 12];
        dc.setColor(mStarHalos[guideLevel], Graphics.COLOR_TRANSPARENT);
        dc.drawLine(130, 10, 130, 19);
        dc.drawLine(126, 14, 134, 14);
        dc.setColor(mStarColors[guideLevel], Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(129, 13, 3, 3);

        // A complete blue world, with simple land shapes and a shaded hemisphere.
        dc.setColor(0x000055, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(208, 154, 10);
        dc.setColor(0x0055AA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(208, 154, 9);
        dc.setColor(0x55AAAA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(205, 151, 5);
        dc.setColor(0x000055, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(211, 157, 5);
        dc.setColor(0x005555, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[203,148],[207,148],[209,150],[207,152],[204,151]]);
        dc.fillPolygon([[206,155],[209,154],[211,156],[210,158],[207,157]]);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.drawPoint(202, 149);
    }

    function drawLandscape(dc) {
        // Far ridge: stepped contours and a black foothill give depth.
        dc.setColor(0x000055, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[0,195],[20,195],[20,188],[39,188],[39,177],
                        [52,177],[52,183],[68,183],[68,178],[84,178],
                        [84,187],[104,187],[104,194],[128,194],[128,190],
                        [145,190],[145,181],[161,181],[161,175],[178,175],
                        [178,180],[193,180],[193,187],[221,187],[221,192],
                        [260,192],[260,260],[0,260]]);
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[0,212],[34,202],[62,204],[89,198],[118,207],
                        [151,201],[181,205],[216,199],[260,211],[260,260],[0,260]]);
        pine(dc, 73, 162, 1, 0x005555);
        pine(dc, 180, 171, 1, 0x005555);
        pine(dc, 36, 140, 2, 0x005555);
        pine(dc, 222, 154, 2, 0x005555);
        pine(dc, 52, 164, 1, 0x555555);
        pine(dc, 203, 174, 1, 0x555555);

        // Front trees: black shadow halves soften the bright MIP teal.
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[36,147],[36,209],[56,209],[49,194],[51,194],
                        [43,181],[45,181],[39,165],[41,165]]);
        dc.fillPolygon([[222,161],[222,223],[242,223],[235,208],[237,208],
                        [229,195],[231,195],[225,179],[227,179]]);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(35, 200, 3, 11);
        dc.fillRectangle(221, 214, 3, 10);

        // A patch of reflected firelight; no expensive gradients or alpha.
        dc.setColor(0x555500, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(130, 208, 39, 7);
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(130, 206, 22, 4);
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        for (var x = 94; x < 170; x += 8) {
            dc.fillRectangle(x, 211, 4, 2);
        }
        dc.fillRectangle(99, 204, 4, 2);
        dc.fillRectangle(153, 209, 5, 2);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(85, 212, 4, 2);
        dc.fillRectangle(171, 213, 5, 2);
        // A little roasting stick is the only human trace in the clearing.
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(92, 205, 116, 186);
        dc.setColor(0xFFFFAA, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(114, 184, 5, 4);
    }

    function pine(dc, x, y, scale, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        // Four overlapping stair-step boughs.
        for (var tier = 0; tier < 4; tier += 1) {
            for (var row = 0; row < 6 + tier; row += 1) {
                var half = (row / 2).toNumber() + tier;
                dc.fillRectangle(x - half * scale, y + (tier * 7 + row) * scale,
                                 (half * 2 + 1) * scale, scale);
            }
        }
        dc.fillRectangle(x - scale, y + 28 * scale, 2 * scale, 7 * scale);
    }

    function drawCampfire(dc, frame, sleeping) {
        var pose = mFlames[frame];
        // Draw runs of each color, rather than allocating sprites every second.
        for (var color = 1; color <= 4; color += 1) {
            dc.setColor(mFireColors[color], Graphics.COLOR_TRANSPARENT);
            for (var row = 0; row < pose.size(); row += 1) {
                var start = -1;
                for (var column = 0; column <= 13; column += 1) {
                    var ink = column < 13 && pose[row].substring(column, column + 1).toNumber() == color;
                    if (ink && start < 0) { start = column; }
                    if (!ink && start >= 0) {
                        dc.fillRectangle(117 + start * 2, 168 + row * 2,
                                         (column - start) * 2, 2);
                        start = -1;
                    }
                }
            }
        }
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(108, 205, 6, 4);
        dc.fillRectangle(115, 209, 5, 3);
        dc.fillRectangle(139, 208, 5, 3);
        dc.fillRectangle(145, 204, 5, 4);
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[115,201],[143,207],[142,211],[114,205]]);
        dc.fillPolygon([[141,200],[144,204],[116,211],[114,207]]);
        dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(121, 205, 4, 2);
        dc.fillRectangle(133, 205, 4, 2);

        if (!sleeping) {
            // Embers drift up and sideways through a full six-second cycle.
            dc.setColor(frame < 4 ? 0xFFAA00 : 0xAA5500, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(133 + frame, 170 - frame * 2, 2, 2);
            dc.setColor(frame < 3 ? 0xAA5500 : 0xFF5500, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(121 - frame, 172 - ((frame + 3) % 6) * 2, 1, 2);
        }
    }
}
