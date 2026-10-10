# Rajdhani Medium and SemiBold

Font copyright: Indian Type Foundry, 2014. Licensed under SIL Open Font License 1.1; see [OFL.txt](OFL.txt).

Source: [Google Fonts / Rajdhani](https://github.com/google/fonts/tree/main/ofl/rajdhani).

`tools/generate-time-font.py` renders the Medium time digits and colon as `Campfire Sky Digits`. It renders the SemiBold activity digits, `k`, `M`, and `-` as `Campfire Activity Digits`, with slightly condensed glyphs to fit the round footer. The activity atlas uses a 128 alpha threshold and non-antialiased font import for firm monochrome strokes at small sizes. Both generated BMFonts are stored in `resources/fonts/` and do not require Pillow when building the watch face.
