using Toybox.Graphics;
using Toybox.Lang;

// Original code-drawn artwork: only colors from the MIP 6-bit RGB cube.
// Coordinates are deliberately composed for the 260-pixel circular display.
class CampfireScene {
    var mStars as Lang.Array<Lang.Array<Lang.Number>> = [
        [77,16], [99,9], [151,14], [174,21], [62,31], [187,34],
        [43,49], [72,43], [166,42], [209,49], [229,69], [31,77],
        [22,105], [43,102], [228,100], [245,123], [17,134],
        [35,139], [62,135], [90,140], [118,133], [145,143],
        [175,131], [236,153], [102,157], [167,157], [156,175],
        [78,172], [181,185], [21,167], [243,181]
    ];
    var mBrightStars as Lang.Array<Lang.Array<Lang.Number>> = [[85,24], [194,63], [38,120], [158,135], [99,178]];
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
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < mStars.size(); i += 1) {
            dc.drawPoint(mStars[i][0], mStars[i][1]);
        }
        for (var j = 0; j < mBrightStars.size(); j += 1) {
            var star = mBrightStars[j];
            dc.setColor(!sleeping && (second + j) % 6 == 0 ? 0xFFFFFF : 0xAAAAAA,
                        Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(star[0], star[1], 2, 2);
        }
        // A quiet, four-point navigation star above the clock.
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(130, 10, 130, 19);
        dc.drawLine(126, 14, 134, 14);
        dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(129, 13, 3, 3);

        // Small ringed world. Two passes let the ring cross the lit hemisphere.
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.drawEllipse(207, 143, 17, 5);
        dc.setColor(0x5555AA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(207, 140, 9);
        dc.setColor(0xAAAAAA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(204, 138, 6);
        dc.setColor(0x5555AA, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(210, 137, 7);
        dc.setColor(0xAAAA55, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(191, 145, 200, 146);
        dc.drawLine(200, 146, 211, 145);
        dc.drawLine(211, 145, 223, 142);
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
        dc.fillEllipse(130, 214, 39, 7);
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.fillEllipse(130, 212, 22, 4);
        dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);
        for (var x = 94; x < 170; x += 8) {
            dc.fillRectangle(x, 217, 4, 2);
        }
        dc.fillRectangle(99, 210, 4, 2);
        dc.fillRectangle(153, 215, 5, 2);
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(85, 218, 4, 2);
        dc.fillRectangle(171, 219, 5, 2);
        // A little roasting stick is the only human trace in the clearing.
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(92, 211, 116, 192);
        dc.setColor(0xFFFFAA, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(114, 190, 5, 4);
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
                        dc.fillRectangle(117 + start * 2, 174 + row * 2,
                                         (column - start) * 2, 2);
                        start = -1;
                    }
                }
            }
        }
        dc.setColor(0x555555, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(108, 211, 6, 4);
        dc.fillRectangle(115, 215, 5, 3);
        dc.fillRectangle(139, 214, 5, 3);
        dc.fillRectangle(145, 210, 5, 4);
        dc.setColor(0xAA5500, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[115,207],[143,213],[142,217],[114,211]]);
        dc.fillPolygon([[141,206],[144,210],[116,217],[114,213]]);
        dc.setColor(0xFFAA00, Graphics.COLOR_TRANSPARENT);
        dc.fillRectangle(121, 211, 4, 2);
        dc.fillRectangle(133, 211, 4, 2);

        if (!sleeping) {
            // Embers drift up and sideways through a full six-second cycle.
            dc.setColor(frame < 4 ? 0xFFAA00 : 0xAA5500, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(133 + frame, 169 - frame * 3, 2, 2);
            dc.setColor(frame < 3 ? 0xAA5500 : 0xFF5500, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(121 - frame, 174 - ((frame + 3) % 6) * 3, 1, 2);
        }
    }
}
