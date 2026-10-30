/*
 * WCAG 2 contrast math. No DOM access, so it can be tested in isolation.
 * https://www.w3.org/TR/WCAG22/#dfn-relative-luminance
 * https://www.w3.org/TR/WCAG22/#dfn-contrast-ratio
 */
"use strict";

window.Contrast = (() => {
    const STANDARDS = [
        { label: "AA-N", name: "AA normal text", ratio: 4.5 },
        { label: "AA-L", name: "AA large text", ratio: 3 },
        { label: "AAA-N", name: "AAA normal text", ratio: 7 },
        { label: "AAA-L", name: "AAA large text", ratio: 4.5 }
    ];

    // Returns "RRGGBB" (upper case) for "#rrggbb" / "rrggbb", otherwise null.
    function parseHex(value) {
        const hex = String(value).trim().replace(/^#/, "").toUpperCase();
        return /^[0-9A-F]{6}$/.test(hex) ? hex : null;
    }

    function luminance(hex) {
        const [r, g, b] = [0, 2, 4].map(i => {
            const c = parseInt(hex.slice(i, i + 2), 16) / 255;
            return c <= 0.04045 ? c / 12.92 : ((c + 0.055) / 1.055) ** 2.4;
        });
        return 0.2126 * r + 0.7152 * g + 0.0722 * b;
    }

    function ratio(a, b) {
        const [lighter, darker] = [luminance(a), luminance(b)].sort((x, y) => y - x);
        return (lighter + 0.05) / (darker + 0.05);
    }

    // WCAG thresholds are never rounded (4.499:1 fails 4.5:1), so the figure
    // shown is truncated, not rounded, and never overstates a pass.
    function formatRatio(value) {
        return (Math.floor(value * 100 + 1e-9) / 100).toFixed(2);
    }

    // Black or white, whichever contrasts more (always at least 4.58:1).
    function readableText(hex) {
        return ratio(hex, "000000") >= ratio(hex, "FFFFFF") ? "#000000" : "#FFFFFF";
    }

    return Object.freeze({ STANDARDS, parseHex, luminance, ratio, formatRatio, readableText });
})();