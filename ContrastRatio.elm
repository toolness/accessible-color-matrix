module ContrastRatio exposing (..)

-- This module provides functionality to calculate color
-- contrast ratios based on the following W3C document:
--
-- https://www.w3.org/TR/WCAG20-TECHS/G17.html

import Color exposing (Color, toRgb)

luminance : Color -> Float
luminance c =
  let
    process channel =
      if channel <= 0.03928
        then channel / 12.92
        else ((channel + 0.055) / 1.055) ^ 2.4
    r = toFloat (toRgb c).red / 255 |> process
    g = toFloat (toRgb c).green / 255 |> process
    b = toFloat (toRgb c).blue / 255 |> process
  in
    0.2126 * r + 0.7152 * g + 0.0722 * b

contrastRatio : Color -> Color -> Float
contrastRatio c1 c2 =
  let
    lum1 = luminance c1
    lum2 = luminance c2
    ratio lighter darker = (lighter + 0.05) / (darker + 0.05)
  in
    if lum1 > lum2 then
      ratio lum1 lum2
      else ratio lum2 lum1
