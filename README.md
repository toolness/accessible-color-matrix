# Accessible Color Matrix

A tool for checking every foreground and background pairing in a color palette against the WCAG 2 contrast requirements. It's a plain HTML, CSS and JavaScript fork of [toolness/accessible-color-matrix](https://github.com/toolness/accessible-color-matrix), with no framework, build step or dependencies.

## Using it

- **Edit the palette.** Choose **Edit palette** to rename colors, change their hex values, add colors or remove them. Changes are applied when you choose **Save changes**; **Cancel** restores the palette as it was.
- **Share a palette.** Saving writes the palette into the page URL (for example `?n=white&v=ffffff&n=black&v=000000`). Copy the URL to share or bookmark it. The browser's back button steps through earlier saved versions.
- **Filter the results.** Pick the minimum ratio to show: any ratio, 3:1, 4.5:1 or 7:1. Pairs below it are left empty. A color that reaches that ratio with no other color is removed from the matrix and named in a note above it.

Each pair shows an “Aa” sample, its contrast ratio and a pass or fail badge for each requirement:

| Badge | Requirement | Minimum ratio |
| ----- | ----------- | ------------- |
| AA-N  | AA, normal text  | 4.5:1 |
| AA-L  | AA, large text   | 3:1   |
| AAA-N | AAA, normal text | 7:1   |
| AAA-L | AAA, large text  | 4.5:1 |

Large text is at least 24 CSS pixels at regular weight, or about 18.7 CSS pixels bold.

## How contrast is calculated

Ratios use the WCAG 2.2 [relative luminance](https://www.w3.org/TR/WCAG22/#dfn-relative-luminance) and [contrast ratio](https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio) definitions. Pass or fail is decided on the exact, unrounded ratio, as WCAG requires. The ratio shown is truncated to two decimal places rather than rounded, so a pair at 4.497:1 is shown as 4.49:1 and never appears to meet 4.5:1 when it doesn't.

## Layout

The matrix fills the available width and never scrolls sideways. Rows are background colors and columns are foreground (text) colors, both sorted from dark to light, and the header row stays in view as the page scrolls.

When there isn't room for every column to be at least 5rem wide, because the screen is narrow, the palette is large or text is zoomed, the matrix becomes a list grouped by background color that shows only the passing pairs.

## Accessibility

The tool aims to meet WCAG 2.2 AA itself:

- Every control is a native HTML element with a visible label, usable by keyboard alone.
- Focus moves somewhere sensible after adding, removing, saving or cancelling, and a status message announces the change.
- Invalid hex values are flagged with a visible error linked to the field, and saving moves focus to the first one.
- Each pair is announced to screen readers as one sentence, for example “bright on black: 11.36 to 1. AA normal text pass, …”, and the visual layout is hidden from them.
- All text and control borders meet the minimum contrast ratios, and the focus ring is two-toned so it shows against any swatch.
- Swatches keep their colors in Windows high contrast (forced colors) mode, since the color is the content.

If you find a barrier, please open an issue.

## Credits

Based on [toolness/accessible-color-matrix](https://github.com/toolness/accessible-color-matrix).
