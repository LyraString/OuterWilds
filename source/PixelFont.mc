using Toybox.Graphics;
using Toybox.Lang;

// Original 5 x 7 glyphs. Rectangles keep the clock sharp on a 64-color MIP.
class PixelFont {
    var mGlyphs as Lang.Dictionary<Lang.String, Lang.Array<Lang.Number>> = {
        "0" => [14, 17, 19, 21, 25, 17, 14],
        "1" => [4, 12, 4, 4, 4, 4, 14],
        "2" => [14, 17, 1, 2, 4, 8, 31],
        "3" => [30, 1, 1, 14, 1, 1, 30],
        "4" => [2, 6, 10, 18, 31, 2, 2],
        "5" => [31, 16, 16, 30, 1, 1, 30],
        "6" => [14, 16, 16, 30, 17, 17, 14],
        "7" => [31, 1, 2, 4, 8, 8, 8],
        "8" => [14, 17, 17, 14, 17, 17, 14],
        "9" => [14, 17, 17, 15, 1, 1, 14],
        "A" => [14, 17, 17, 31, 17, 17, 17],
        "D" => [30, 17, 17, 17, 17, 17, 30],
        "E" => [31, 16, 16, 30, 16, 16, 31],
        "F" => [31, 16, 16, 30, 16, 16, 16],
        "H" => [17, 17, 17, 31, 17, 17, 17],
        "I" => [14, 4, 4, 4, 4, 4, 14],
        "M" => [17, 27, 21, 21, 17, 17, 17],
        "N" => [17, 25, 25, 21, 19, 19, 17],
        "O" => [14, 17, 17, 17, 17, 17, 14],
        "P" => [30, 17, 17, 30, 16, 16, 16],
        "R" => [30, 17, 17, 30, 20, 18, 17],
        "S" => [15, 16, 16, 14, 1, 1, 30],
        "T" => [31, 4, 4, 4, 4, 4, 4],
        "U" => [17, 17, 17, 17, 17, 17, 14],
        "W" => [17, 17, 17, 21, 21, 27, 17],
        ":" => [0, 16, 16, 0, 16, 16, 0],
        "." => [0, 0, 0, 0, 0, 0, 16],
        "-" => [0, 0, 0, 31, 0, 0, 0]
    };

    function initialize() {}

    function glyphWidth(character) {
        if (character.equals(":")) { return 1; }
        if (character.equals(".")) { return 1; }
        if (character.equals(" ")) { return 3; }
        return 5;
    }

    function width(text, scale, spacing) {
        var result = 0;
        for (var i = 0; i < text.length(); i += 1) {
            result += glyphWidth(text.substring(i, i + 1)) * scale;
            if (i > 0) { result += spacing; }
        }
        return result;
    }

    function draw(dc, text, center, y, scale, spacing, color) {
        var x = (center - width(text, scale, spacing) / 2).toNumber();
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < text.length(); i += 1) {
            var character = text.substring(i, i + 1);
            var columns = glyphWidth(character);
            var rows = mGlyphs[character];
            if (rows != null) {
                for (var row = 0; row < 7; row += 1) {
                    // Coalesce adjacent pixels into one draw call.
                    var start = -1;
                    for (var column = 0; column <= columns; column += 1) {
                        var ink = column < columns && (rows[row] & (16 >> column)) != 0;
                        if (ink && start < 0) { start = column; }
                        if (!ink && start >= 0) {
                            dc.fillRectangle(x + start * scale, y + row * scale,
                                             (column - start) * scale, scale);
                            start = -1;
                        }
                    }
                }
            }
            x += columns * scale + spacing;
        }
    }
}
