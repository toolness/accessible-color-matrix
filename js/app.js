"use strict";

(() => {
    const {
        LEVELS,
        LARGE_TEXT,
        textCategory,
        requirements,
        parseHex,
        luminance,
        ratio,
        formatRatio,
        readableText
    } = window.Contrast;

    const DEFAULT_PALETTE = [
        ["white", "FFFFFF"],
        ["light", "B3EFFF"],
        ["bright", "00CFFF"],
        ["medium", "046B99"],
        ["dark", "1C304A"],
        ["black", "000000"]
    ];

    const $ = id => document.getElementById(id);

    let palette = loadPalette();
    let snapshot = [];
    let editing = false;

    function makeColor(id, name, hex) {
        return { id, name, hex, draft: hex };
    }

    function label(color) {
        return color.name.trim() || "#" + color.hex;
    }

    function loadPalette() {
        const params = new URLSearchParams(location.search);
        const values = params.getAll("v");
        const colors = [];

        params.getAll("n").forEach((name, i) => {
            const hex = parseHex(values[i] ?? "");
            if (hex) colors.push(makeColor(colors.length, name, hex));
        });

        return colors.length ? colors :
            DEFAULT_PALETTE.map(([name, hex], i) => makeColor(i, name, hex));
    }

    function saveToURL() {
        const params = new URLSearchParams();
        palette.forEach(c => {
            params.append("n", c.name);
            params.append("v", c.hex.toLowerCase());
        });
        try {
            history.pushState(null, "", "?" + params);
        } catch {
            // Some browsers refuse pushState on file:// pages; the app still works.
        }
    }

    function el(tag, props = {}, ...children) {
        const node = Object.assign(document.createElement(tag), props);
        node.append(...children);
        return node;
    }

    function button(text, onClick, className = "") {
        const node = el("button", { type: "button", className, textContent: text });
        node.addEventListener("click", onClick);
        return node;
    }

    function paint(node, hex) {
        node.style.backgroundColor = "#" + hex;
        node.style.color = readableText(hex);
    }

    function announce(message) {
        $("status").textContent = message;
    }

    function renderPalette() {
        const items = palette.map(editing ? editableSwatch : staticSwatch);
        if (editing) {
            items.push(el("li", {}, button("+ Add color", addColor, "add")));
        }
        $("palette").replaceChildren(...items);
    }

    function staticSwatch(color) {
        const item = el("li", { className: "swatch" },
            el("p", { textContent: label(color) }),
            el("p", { textContent: "#" + color.hex }));
        paint(item, color.hex);
        return item;
    }

    function editableSwatch(color, index) {
        const item = el("li", { className: "swatch editing" });
        paint(item, color.hex);

        const nameInput = el("input", { id: "name-" + color.id, value: color.name, autocomplete: "off" });
        const hexInput = el("input", { id: "hex-" + color.id, value: color.draft, autocomplete: "off", spellcheck: false });
        const picker = el("input", { id: "pick-" + color.id, type: "color", value: "#" + color.hex });
        const error = el("p", {
            id: "error-" + color.id,
            className: "error",
            textContent: "Enter 6 hex digits, for example 1C304A."
        });

        function showError(show) {
            error.hidden = !show;
            if (show) {
                hexInput.setAttribute("aria-invalid", "true");
                hexInput.setAttribute("aria-describedby", error.id);
            } else {
                hexInput.removeAttribute("aria-invalid");
                hexInput.removeAttribute("aria-describedby");
            }
        }

        function applyHex(hex) {
            color.hex = hex;
            picker.value = "#" + hex;
            paint(item, hex);
            renderMatrix();
        }

        let remove = null;
        if (palette.length > 1) {
            remove = button("×", () => removeColor(color), "remove");
            remove.setAttribute("aria-label", "Remove " + label(color));
            item.append(remove);
        }

        nameInput.addEventListener("input", () => {
            color.name = nameInput.value;
            remove?.setAttribute("aria-label", "Remove " + label(color));
            renderMatrix();
        });

        hexInput.addEventListener("input", () => {
            color.draft = hexInput.value;
            const hex = parseHex(color.draft);
            if (hex) {
                showError(false);
                applyHex(hex);
            }
        });

        hexInput.addEventListener("change", () => showError(!parseHex(color.draft)));

        picker.addEventListener("input", () => {
            color.draft = hexInput.value = picker.value.slice(1).toUpperCase();
            showError(false);
            applyHex(color.draft);
        });

        showError(!parseHex(color.draft));

        item.append(el("fieldset", {},
            el("legend", { className: "visually-hidden", textContent: "Color " + (index + 1) }),
            el("label", { htmlFor: nameInput.id, textContent: "Name" }), nameInput,
            el("label", { htmlFor: hexInput.id, textContent: "Hex value" }), hexInput, error,
            el("label", { htmlFor: picker.id, textContent: "Picker" }), picker));

        return item;
    }

    function addColor() {
        const id = Math.max(-1, ...palette.map(c => c.id)) + 1;
        const color = makeColor(id, "Color " + (palette.length + 1), "FF0000");
        palette.push(color);
        render();
        $("name-" + id).focus();
        announce(color.name + " added.");
    }

    function removeColor(color) {
        const index = palette.indexOf(color);
        palette = palette.filter(c => c !== color);
        render();
        // Keep focus in the palette rather than letting it fall back to <body>.
        $("name-" + palette[Math.min(index, palette.length - 1)].id).focus();
        announce(label(color) + " removed.");
    }

    function renderActions() {
        $("actions").replaceChildren(...(editing ? [button("Save changes", saveEditing), button("Cancel", cancelEditing, "secondary")] : [button("Edit palette", startEditing)]));
    }

    function focusActions() {
        $("actions").querySelector("button").focus();
    }

    function startEditing() {
        snapshot = palette.map(c => ({ ...c }));
        editing = true;
        render();
        $("name-" + palette[0].id).focus();
    }

    function saveEditing() {
        const invalid = palette.find(c => !parseHex(c.draft));
        if (invalid) {
            renderPalette();
            $("hex-" + invalid.id).focus();
            return;
        }
        palette.forEach(c => {
            c.hex = c.draft = parseHex(c.draft);
            c.name = label(c);
        });
        editing = false;
        saveToURL();
        render();
        focusActions();
        announce("Palette saved.");
    }

    function cancelEditing() {
        palette = snapshot;
        editing = false;
        render();
        focusActions();
        announce("Changes discarded.");
    }

    const MAX_SAMPLE_PX = 48;
    let filterKey = "aa";
    let filterCategory;

    function textSettings() {
        const input = $("font-size");
        const raw = input.value.trim();
        const px = Number(raw);
        const valid = raw !== "" && Number.isFinite(px) && px > 0;
        const weight = Number($("font-weight").value);
        return {
            px: valid ? px : null,
            invalid: !valid && (raw !== "" || input.validity.badInput),
            weight,
            family: $("font-family").value.trim(),
            category: valid ? textCategory(px, weight) : null
        };
    }

    const trim = n => String(+n.toFixed(2));

    function describeText(text) {
        if (text.invalid) {
            return "Enter a font size above 0, or leave it empty to see every requirement.";
        }
        if (!text.category) {
            return "No size entered, so every pair shows all four requirements. " +
                "Enter the size of your text to see only the ones that apply.";
        }
        const { aa, aaa } = LEVELS[text.category];
        const bold = text.weight >= LARGE_TEXT.boldWeight;
        const parts = [`${trim(text.px)}px (${trim(text.px * 0.75)}pt) at weight ${text.weight} is ` +
            `${text.category} text, so AA needs ${aa}:1 and AAA needs ${aaa}:1.`
        ];

        if (text.category === "normal") {
            parts.push(bold ?
                `Bold text counts as large from ${LARGE_TEXT.boldPx}px.` :
                `It would count as large text at ${LARGE_TEXT.px}px, or at ${LARGE_TEXT.boldPx}px ` +
                `with weight ${LARGE_TEXT.boldWeight} or more.`);
        }
        if (text.category === "normal" && text.weight >= 500 && !bold && text.px >= LARGE_TEXT.boldPx) {
            parts.push(`WCAG doesn’t give a number for bold, so weights below ${LARGE_TEXT.boldWeight} ` +
                "count as regular here.");
        }
        if (text.weight <= 300) {
            parts.push("Thin strokes are harder to read at low contrast, so aim above the minimum.");
        }
        return parts.join(" ");
    }

    // With a known size, "AA" and "AAA" mean that text's thresholds. Without one,
    // the four fixed ratios are offered. The keys line up so a choice carries over.
    function filterOptions(category) {
        const options = [{ key: "any", ratio: 0, text: "Any ratio (show all)" }];
        if (category) {
            const { aa, aaa } = LEVELS[category];
            options.push({ key: "aa", ratio: aa, text: `AA for this text (${aa}:1)` }, { key: "aaa", ratio: aaa, text: `AAA for this text (${aaa}:1)` });
        } else {
            options.push({ key: "aa-large", ratio: LEVELS.large.aa, text: `AA large text (${LEVELS.large.aa}:1)` }, { key: "aa", ratio: LEVELS.normal.aa, text: `AA normal text (${LEVELS.normal.aa}:1)` }, { key: "aaa", ratio: LEVELS.normal.aaa, text: `AAA normal text (${LEVELS.normal.aaa}:1)` });
        }
        return options;
    }

    function renderFilter(category) {
        const options = filterOptions(category);
        if (!options.some(o => o.key === filterKey)) filterKey = "aa";
        $("filter-options").replaceChildren(...options.map(o =>
            el("label", {},
                el("input", { type: "radio", name: "min-ratio", value: o.key, checked: o.key === filterKey }),
                " " + o.text)));
        filterCategory = category;
    }

    function updateTextControls(text) {
        const size = $("font-size");
        if (text.invalid) size.setAttribute("aria-invalid", "true");
        else size.removeAttribute("aria-invalid");
        $("text-summary").textContent = describeText(text);
        // Rebuild the radios only when the category changes, not on every keystroke.
        if (text.category !== filterCategory) renderFilter(text.category);
    }

    // Narrowest readable column. Below this the matrix becomes a list instead of
    // scrolling. In rem, so zooming text also triggers the switch (WCAG 1.4.10).
    const MIN_COLUMN_REM = 5;
    let layout = null; // "table" or "list", whichever was rendered last

    function chip(color) {
        const node = el("span", { className: "chip", textContent: "#" + color.hex });
        paint(node, color.hex);
        return node;
    }

    function colorHeader(color, scope) {
        return el("th", { scope }, chip(color), el("span", { className: "header-name", textContent: label(color) }));
    }

    function pairContent(fg, bg, value, showName, text) {
        const shown = formatRatio(value);
        const results = requirements(text.category).map(s => ({ ...s, pass: value >= s.ratio }));

        const sample = el("span", { className: "sample", textContent: "Aa" });
        sample.style.color = "#" + fg.hex;
        sample.style.backgroundColor = "#" + bg.hex;
        sample.style.fontWeight = text.weight;
        sample.style.fontFamily = text.family;
        if (text.px) sample.style.fontSize = Math.min(text.px, MAX_SAMPLE_PX) + "px";

        const spoken = el("span", {
            className: "visually-hidden",
            textContent: `${label(fg)} on ${label(bg)}: ${shown} to 1. ` +
                results.map(s => `${s.name} ${s.pass ? "pass" : "fail"}`).join(", ") + "."
        });

        const visual = el("div", {},
            showName ? el("span", { className: "pair-name", textContent: label(fg) }) : "",
            sample,
            el("span", { className: "ratio", textContent: shown + ":1" }),
            el("div", { className: "badges" }, ...results.map(s =>
                el("span", {
                    className: "badge " + (s.pass ? "pass" : "fail"),
                    textContent: s.label + " " + (s.pass ? "✓" : "✗")
                }))));
        visual.setAttribute("aria-hidden", "true");

        return [spoken, visual];
    }

    function buildTable(colors, minRatio, text) {
        const corner = el("td", { className: "corner" },
            el("span", {}, "Foreground\u00a0→", el("br"), "Background\u00a0↓"));
        corner.firstChild.setAttribute("aria-hidden", "true");

        const cell = (fg, bg) => {
            const value = ratio(fg.hex, bg.hex);
            // Filtered out: the cell must stay so the columns line up, but it stays empty.
            return value < minRatio ? el("td") : el("td", {}, ...pairContent(fg, bg, value, false, text));
        };

        return el("table", {},
            el("caption", {
                className: "visually-hidden",
                textContent: "Rows are background colors, columns are foreground (text) colors, " +
                    "both sorted dark to light. Empty cells are below the chosen ratio." +
                    (text.category ? ` Results are for ${trim(text.px)}px ${text.category} text.` : "")
            }),
            el("thead", {}, el("tr", {}, corner, ...colors.map(c => colorHeader(c, "col")))),
            el("tbody", {}, ...colors.map(bg =>
                el("tr", {}, colorHeader(bg, "row"), ...colors.map(fg => cell(fg, bg))))));
    }

    function buildList(colors, minRatio, text) {
        return el("div", { className: "pair-list" }, ...colors.flatMap(bg => {
            const pairs = colors
                .map(fg => [fg, ratio(fg.hex, bg.hex)])
                .filter(([, value]) => value >= minRatio);
            return [
                el("h3", {}, el("span", { textContent: "On " + label(bg) }), chip(bg)),
                el("ul", { className: "pairs" }, ...pairs.map(([fg, value]) =>
                    el("li", {}, ...pairContent(fg, bg, value, true, text))))
            ];
        }));
    }

    function fitsAsTable(columns) {
        const rem = parseFloat(getComputedStyle(document.documentElement).fontSize);
        return $("matrix").clientWidth >= columns * MIN_COLUMN_REM * rem;
    }

    function setNote(text) {
        const note = $("matrix-note");
        if (note.textContent !== text) note.textContent = text;
    }

    function visibleColors(minRatio) {
        const sorted = [...palette].sort((a, b) => luminance(a.hex) - luminance(b.hex));
        return sorted.filter(a => sorted.some(b => ratio(a.hex, b.hex) >= minRatio));
    }

    function minRatio() {
        return filterOptions(filterCategory).find(o => o.key === filterKey)?.ratio ?? 0;
    }

    function renderMatrix() {
        const text = textSettings();
        const min = minRatio();
        const colors = visibleColors(min);
        const removed = palette.filter(c => !colors.includes(c)).map(label);

        if (!colors.length) {
            setNote(`No combination reaches ${min}:1.`);
        } else if (removed.length) {
            setNote(`Not shown, because they reach ${min}:1 with no other color: ${removed.join(", ")}.`);
        } else {
            setNote("");
        }

        const matrix = $("matrix");
        matrix.hidden = !colors.length;
        if (!colors.length) return;

        layout = fitsAsTable(colors.length + 1) ? "table" : "list";
        matrix.replaceChildren(layout === "table" ? buildTable(colors, min, text) : buildList(colors, min, text));
    }

    new ResizeObserver(() => {
        const colors = visibleColors(minRatio());
        if (colors.length && (fitsAsTable(colors.length + 1) ? "table" : "list") !== layout) {
            renderMatrix();
        }
    }).observe($("matrix"));

    function render() {
        renderPalette();
        renderActions();
        renderMatrix();
    }

    $("ratio-filter").addEventListener("change", event => {
        filterKey = event.target.value;
        renderMatrix();
    });

    $("text-settings").addEventListener("input", () => {
        updateTextControls(textSettings());
        renderMatrix();
    });

    window.addEventListener("popstate", () => {
        palette = loadPalette();
        editing = false;
        render();
    });

    updateTextControls(textSettings());
    render();
})();