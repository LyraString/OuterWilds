"""Build the time and activity BMFonts used by the watch face (requires Pillow)."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parent.parent
output = root / 'resources' / 'fonts'
output.mkdir(parents=True, exist_ok=True)


def generate(source, font_size, characters, filename, face, atlas_size, tracking, x_scale=1, monochrome=False):
    font = ImageFont.truetype(str(root / 'tools/assets/rajdhani' / source), font_size)
    boxes = {character: font.getbbox(character) for character in characters}
    top = min(box[1] for box in boxes.values())
    height = max(box[3] for box in boxes.values()) - top
    atlas = Image.new('RGBA', atlas_size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(atlas)
    glyphs = []
    cursor = 0
    for character in characters:
        left, upper, right, lower = boxes[character]
        width = max(1, round((right - left) * x_scale))
        glyph_height = lower - upper
        if x_scale == 1:
            draw.text((cursor - left, -upper), character, font=font, fill=(255, 255, 255, 255))
        else:
            glyph = Image.new('RGBA', (right - left, glyph_height), (255, 255, 255, 0))
            ImageDraw.Draw(glyph).text((-left, -upper), character, font=font, fill=(255, 255, 255, 255))
            glyph = glyph.resize((width, glyph_height), Image.Resampling.LANCZOS)
            atlas.paste(glyph, (cursor, 0))
        advance = max(width, round(font.getlength(character) * x_scale) + tracking)
        glyphs.append(f'char id={ord(character)} x={cursor} y=0 width={width} height={glyph_height} xoffset={round(left * x_scale)} yoffset={upper - top} xadvance={advance} page=0 chnl=15')
        cursor += width + 2
    assert cursor <= atlas.width and height <= atlas.height
    if monochrome:
        # Firm one-bit strokes avoid faint resampling edges in tiny MIP digits.
        atlas.putalpha(atlas.getchannel('A').point(lambda value: 255 if value >= 128 else 0))
    atlas.save(output / f'{filename}.png')
    header = [
        f'info face="{face}" size={font_size} bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0 outline=0',
        f'common lineHeight={height} base={height} scaleW={atlas.width} scaleH={atlas.height} pages=1 packed=0 alphaChnl=1 redChnl=0 greenChnl=0 blueChnl=0',
        f'page id=0 file="{filename}.png"',
        f'chars count={len(characters)}',
    ]
    (output / f'{filename}.fnt').write_text('\n'.join(header + glyphs) + '\n', encoding='utf-8')
    print(f'Generated {filename}: {len(characters)} glyphs, {height}px line height; source: {source} (SIL OFL 1.1).')


generate('Rajdhani-Medium.ttf', 80, '0123456789:', 'campfire-time',
         'Campfire Sky Digits', (512, 64), tracking=2)
generate('Rajdhani-SemiBold.ttf', 21, '0123456789kM-', 'campfire-activity',
         'Campfire Activity Digits', (256, 32), tracking=1, x_scale=0.85, monochrome=True)
