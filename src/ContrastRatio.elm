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

areColorsIndistinguishable : Color -> Color -> Bool
areColorsIndistinguishable c1 c2 =
  contrastRatio c1 c2 < 1.1

humanFriendlyContrastRatio : Float -> String
humanFriendlyContrastRatio ratio =
  -- Um, Elm doesn't seem to have any built-in functionality
  -- for formatting floats to strings, so I guess we'll have
  -- to improvise...
  let
    intPart = toString (floor ratio)
    decimalPart numDigits =
      toString (floor ((ratio - (toFloat (floor ratio))) * 10 ^ numDigits))
    numDigits =
      if ratio < 4 then 1 else if ratio < 5 then 2 else 0
  in
    intPart ++
      (if numDigits > 0 then "." ++ decimalPart numDigits else "") ++
        ":1"
